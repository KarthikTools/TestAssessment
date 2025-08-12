package com.demo.pay.core;

import com.demo.pay.core.dto.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class PaymentService {
    private static final Logger logger = LoggerFactory.getLogger(PaymentService.class);

    private final WebClient riskClient, tokClient;
    private final JdbcTemplate jdbc;
    private final KafkaTemplate<String, String> kafka;
    private final String topic;

    public PaymentService(
            @Value("${app.riskBaseUrl}") String riskBase,
            @Value("${app.tokenizeBaseUrl}") String tokBase,
            KafkaTemplate<String, String> kafka,
            @Value("${app.kafka.topic}") String topic,
            JdbcTemplate jdbc) {

        this.riskClient = WebClient.builder().baseUrl(riskBase).build();
        this.tokClient = WebClient.builder().baseUrl(tokBase).build();
        this.jdbc = jdbc;
        this.kafka = kafka;
        this.topic = topic;
    }

    public Mono<PaymentResponse> createPayment(CreatePaymentRequest req) {
        logger.info("Processing payment request: payerId={}, payeeId={}, amount={}, currency={}", 
                   req.payerId(), req.payeeId(), req.amount(), req.currency());

        return riskClient.get()
            .uri(uri -> uri.path("/risk")
                .queryParam("payerId", req.payerId())
                .queryParam("amount", req.amount())
                .queryParam("currency", req.currency())
                .build())
            .retrieve()
            .bodyToMono(RiskResponse.class)
            .flatMap(risk -> {
                logger.info("Risk assessment: score={}, decision={}, txnId={}", 
                           risk.riskScore(), risk.decision(), risk.txnId());

                if ("REJECT".equals(risk.decision())) {
                    persist(req, risk, null, null, "DECLINED");
                    return Mono.just(new PaymentResponse(risk.txnId(), "DECLINED", 
                                                       risk.riskScore(), null, null));
                }

                return tokClient.post()
                    .uri("/tokenize")
                    .bodyValue(req)
                    .retrieve()
                    .bodyToMono(TokenizeResponse.class)
                    .map(tok -> {
                        String status = "APPROVE".equals(risk.decision()) ? "CREATED" : "PENDING_REVIEW";
                        persist(req, risk, tok.panToken(), tok.iban(), status);
                        
                        if ("CREATED".equals(status)) {
                            String event = String.format("{\"event\":\"PaymentCreated\",\"txnId\":\"%s\",\"amount\":%.2f,\"currency\":\"%s\"}", 
                                                       risk.txnId(), req.amount(), req.currency());
                            kafka.send(topic, risk.txnId(), event);
                            logger.info("Published Kafka event for txnId: {}", risk.txnId());
                        }
                        
                        return new PaymentResponse(risk.txnId(), status, risk.riskScore(), 
                                                 tok.panToken(), tok.iban());
                    });
            })
            .onErrorResume(e -> {
                logger.error("Error processing payment: {}", e.getMessage(), e);
                return Mono.error(e);
            });
    }

    public Mono<PaymentResponse> getPayment(String txnId) {
        return Mono.fromCallable(() ->
            jdbc.queryForObject(
                "SELECT txn_id, risk_score, status, pan_token, iban FROM payments WHERE txn_id = ?",
                (rs, n) -> new PaymentResponse(
                    rs.getString("txn_id"),
                    rs.getString("status"),
                    rs.getInt("risk_score"),
                    rs.getString("pan_token"),
                    rs.getString("iban")),
                txnId));
    }

    private void persist(CreatePaymentRequest req, RiskResponse risk, String token, String iban, String status) {
        try {
            jdbc.update("""
                INSERT INTO payments(txn_id, payer_id, payee_id, amount, currency, risk_score, decision, pan_token, iban, status)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT (txn_id) DO UPDATE SET 
                    status = EXCLUDED.status, 
                    pan_token = EXCLUDED.pan_token, 
                    iban = EXCLUDED.iban
                """,
                risk.txnId(), req.payerId(), req.payeeId(), req.amount(), req.currency(), 
                risk.riskScore(), risk.decision(), token, iban, status);
            
            logger.info("Persisted payment: txnId={}, status={}", risk.txnId(), status);
        } catch (Exception e) {
            logger.error("Failed to persist payment: {}", e.getMessage(), e);
            throw new RuntimeException("Database persistence failed", e);
        }
    }
}

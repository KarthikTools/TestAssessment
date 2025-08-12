package com.demo.wm;

import com.github.tomakehurst.wiremock.extension.ResponseDefinitionTransformer;
import com.github.tomakehurst.wiremock.http.*;
import com.github.tomakehurst.wiremock.client.ResponseDefinitionBuilder;
import com.github.tomakehurst.wiremock.extension.Parameters;
import com.github.tomakehurst.wiremock.common.FileSource;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Map;

public class RiskTransformer extends ResponseDefinitionTransformer {

    @Override 
    public String getName() { 
        return "risk-transformer"; 
    }
    
    @Override 
    public boolean applyGlobally() { 
        return false; 
    }

    @Override
    public ResponseDefinition transform(Request req, ResponseDefinition resp, FileSource files, Parameters params) {
        QueryParameter payer = req.queryParameter("payerId");
        QueryParameter amount = req.queryParameter("amount");
        QueryParameter currency = req.queryParameter("currency");
        
        String payerId = payer.isPresent() ? payer.firstValue() : "UNKNOWN";
        String amtStr = amount.isPresent() ? amount.firstValue() : "0";
        String ccy = currency.isPresent() ? currency.firstValue() : "CAD";

        double amt = 0.0;
        try { 
            amt = Double.parseDouble(amtStr); 
        } catch (Exception ignored) {}

        // deterministic risk in [55..95] based on payerId+amount
        int hash = Math.abs((payerId + "|" + amtStr + "|" + ccy).hashCode());
        int risk = 55 + (hash % 41); // 55..95
        String decision = risk >= 85 ? "APPROVE" : (risk >= 70 ? "REVIEW" : "REJECT");

        // deterministic txnId (HMAC-SHA256 truncated to 16 hex)
        String secret = System.getenv().getOrDefault("HMAC_SECRET", "demo-secret");
        String material = payerId + "|" + amtStr + "|" + ccy;
        String txnId = hmacSha256Hex(secret, material).substring(0, 16);

        String body = String.format(
            "{\"payerId\":\"%s\",\"amount\":%s,\"currency\":\"%s\",\"riskScore\":%d,\"decision\":\"%s\",\"txnId\":\"%s\"}",
            payerId, amtStr, ccy, risk, decision, txnId
        );

        return ResponseDefinitionBuilder.like(resp)
            .but()
            .withStatus(200)
            .withHeader("Content-Type", "application/json")
            .withBody(body)
            .build();
    }

    private static String hmacSha256Hex(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : raw) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) { 
            throw new RuntimeException(e); 
        }
    }
}

package com.demo.pay.api;

import com.demo.pay.core.PaymentService;
import com.demo.pay.core.dto.CreatePaymentRequest;
import com.demo.pay.core.dto.PaymentResponse;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/payments")
@CrossOrigin(origins = "*")
public class PaymentController {
    private final PaymentService svc;
    
    public PaymentController(PaymentService svc) { 
        this.svc = svc; 
    }

    @PostMapping
    public Mono<PaymentResponse> create(@RequestBody CreatePaymentRequest req) {
        return svc.createPayment(req);
    }

    @GetMapping("/{txnId}")
    public Mono<PaymentResponse> get(@PathVariable String txnId) {
        return svc.getPayment(txnId);
    }
    
    @GetMapping("/health")
    public Mono<String> health() {
        return Mono.just("OK");
    }
}

package com.demo.pay.core.dto;

public record RiskResponse(String payerId, double amount, String currency, int riskScore, String decision, String txnId) {}

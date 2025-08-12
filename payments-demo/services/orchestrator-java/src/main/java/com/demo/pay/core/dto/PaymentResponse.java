package com.demo.pay.core.dto;

public record PaymentResponse(String txnId, String status, int riskScore, String panToken, String iban) {}

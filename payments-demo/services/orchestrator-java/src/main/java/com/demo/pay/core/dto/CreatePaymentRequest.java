package com.demo.pay.core.dto;

public record CreatePaymentRequest(String payerId, String payeeId, double amount, String currency) {}

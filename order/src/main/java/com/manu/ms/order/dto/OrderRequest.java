package com.manu.ms.order.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class OrderRequest {
    private String orderNumber;
    private String skuCode;
    private BigDecimal price;
    private Integer quantity;
    private UserDetails userDetails;

    public record UserDetails(String email, String firstName, String lastName) {}

}
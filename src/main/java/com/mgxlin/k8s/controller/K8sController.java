package com.mgxlin.k8s.controller;


import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class K8sController {

    @GetMapping
    public String k8s() {
        return "Hello k8s!";
    }
}

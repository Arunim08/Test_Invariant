package com.app;

import java.net.InetAddress;
import java.util.HashMap;
import java.util.Map;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @GetMapping("/")
    public String hello() {
        return "Hello from App-10 (Java Spring Boot Service)! ☕\n";
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("app", "app-10");
        return response;
    }

    @GetMapping("/info")
    public Map<String, Object> info() {
        Map<String, Object> response = new HashMap<>();
        try {
            response.put("app", "app-10");
            response.put("type", "Java Spring Boot");
            response.put("hostname", InetAddress.getLocalHost().getHostName());
            response.put("java_version", System.getProperty("java.version"));
        } catch (Exception e) {
            response.put("error", e.getMessage());
        }
        return response;
    }

    @GetMapping("/api/status")
    public Map<String, Object> status() {
        Map<String, Object> response = new HashMap<>();
        Runtime runtime = Runtime.getRuntime();
        response.put("app", "app-10");
        response.put("uptime_ms", System.currentTimeMillis());
        response.put("memory_used_mb", (runtime.totalMemory() - runtime.freeMemory()) / 1024 / 1024);
        response.put("memory_max_mb", runtime.maxMemory() / 1024 / 1024);
        return response;
    }
}

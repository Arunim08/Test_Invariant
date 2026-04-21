package com.invariant.demo.api;

import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.Map;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class TestController {

  @GetMapping("/hello")
  public Map<String, Object> hello() {
    Map<String, Object> out = new HashMap<>();
    out.put("message", "hello");
    out.put("service", "springboot-demo-app");
    out.put("timestamp", OffsetDateTime.now().toString());
    return out;
  }

  @GetMapping("/time")
  public Map<String, Object> time() {
    Map<String, Object> out = new HashMap<>();
    out.put("now", OffsetDateTime.now().toString());
    return out;
  }

  @PostMapping(value = "/echo", consumes = MediaType.APPLICATION_JSON_VALUE)
  public Map<String, Object> echo(@RequestBody Map<String, Object> body) {
    Map<String, Object> out = new HashMap<>();
    out.put("echo", body);
    return out;
  }

  @GetMapping("/env")
  public Map<String, Object> env() {
    Map<String, Object> out = new HashMap<>();
    out.put("serviceName", getenv("SERVICE_NAME"));
    out.put("environment", getenv("ENVIRONMENT"));
    out.put("gitSha", getenv("GIT_SHA"));
    out.put("podName", getenv("POD_NAME"));
    out.put("nodeName", getenv("NODE_NAME"));
    return out;
  }

  private static String getenv(String name) {
    String v = System.getenv(name);
    return v == null ? "" : v;
  }
}


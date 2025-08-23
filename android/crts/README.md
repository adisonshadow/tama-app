

```bash
# 导出 Google 的证书
echo -n | openssl s_client -connect dl.google.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > google.crt

# 导出 Maven 的证书  
echo -n | openssl s_client -connect repo.maven.apache.org:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > maven.crt

# 找到 JDK 的 cacerts 文件

# 导入 Google 证书
keytool -importcert -alias google -keystore /Users/yanfang/.sdkman/candidates/java/current/lib/security/cacerts -file google.crt

# 导入 Maven 证书
keytool -importcert -alias maven -keystore /Users/yanfang/.sdkman/candidates/java/current/lib/security/cacerts -file maven.crt

# 默认密码：changeit

```

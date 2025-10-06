# KnowledgeChain - 智能知识管理系统

## 🎯 项目简介

KnowledgeChain是一个基于Spring Boot + Milvus + BGE嵌入的智能知识管理系统，实现了完整的RAG（检索增强生成）工作流，支持多模型LLM集成和混合搜索功能。

## 🚀 技术栈

- **后端框架**：Spring Boot 3.2.0 + Java 17
- **向量数据库**：Milvus 2.6.0
- **嵌入模型**：BGE (BAAI General Embedding)
- **对象存储**：MinIO
- **数据库**：MySQL 8.0 / H2
- **缓存**：Redis
- **协调服务**：Zookeeper
- **LLM集成**：Qwen、OpenAI GPT、DeepSeek

## ✨ 核心功能

### 📚 文档管理
- 支持多种文档格式（PDF、Word、Excel、PPT、图片等）
- 智能文档解析和内容提取
- 文档向量化和索引构建
- 多租户数据隔离

### 🔍 智能搜索
- **向量搜索**：基于语义相似度的搜索
- **关键词搜索**：传统文本匹配搜索
- **混合搜索**：结合向量和关键词的智能搜索
- **RAG工作流**：检索增强生成

### 🤖 LLM集成
- **多模型支持**：Qwen、OpenAI、DeepSeek
- **流式输出**：实时响应生成
- **上下文管理**：智能对话上下文
- **提示模板**：可配置的提示词模板

### 🏢 企业功能
- **多租户架构**：数据隔离和权限管理
- **用户认证**：完整的用户管理系统
- **API接口**：RESTful API设计
- **监控日志**：完整的操作日志记录

## 🛠️ 快速开始

### 环境要求
- Java 17+
- Maven 3.6+
- MySQL 8.0+ 或 H2
- Redis 6.0+
- Milvus 2.6.0+
- MinIO

### 启动步骤

1. **启动依赖服务**
   ```bash
   ./start-deps.sh
   ```

2. **启动应用（MySQL模式）**
   ```bash
   ./start-with-mysql.sh
   ```

3. **启动应用（H2模式）**
   ```bash
   ./start-h2.sh
   ```

4. **访问应用**
   - 应用地址：http://localhost:29092
   - 健康检查：http://localhost:29092/actuator/health

### 服务管理

```bash
# 启动所有服务
./start-services.sh start

# 停止所有服务
./stop-services.sh

# 检查服务状态
./check-services.sh
```

## 📁 项目结构

```
knowledgechain/
├── src/                           # 源代码
│   ├── main/java/com/knowledgechain/
│   │   ├── controller/            # 控制器层
│   │   ├── service/              # 服务层
│   │   ├── entity/               # 实体类
│   │   ├── dto/                  # 数据传输对象
│   │   ├── config/               # 配置类
│   │   └── util/                 # 工具类
│   └── main/resources/           # 资源文件
├── target/                       # 编译输出
├── logs/                         # 日志文件
├── start-*.sh                   # 启动脚本
├── test-*.sh                    # 测试脚本
├── pom.xml                      # Maven配置
└── README.md                    # 项目说明
```

## 🔧 配置说明

### 数据库配置
- **MySQL模式**：生产环境推荐
- **H2模式**：开发测试环境

### 向量数据库配置
- **Milvus连接**：默认localhost:19530
- **集合管理**：自动创建和管理向量集合

### LLM配置
- **Qwen API**：阿里云通义千问
- **OpenAI API**：OpenAI GPT模型
- **DeepSeek API**：DeepSeek模型

## 📊 API接口

### 文档管理
- `POST /api/documents/upload` - 上传文档
- `GET /api/documents/list` - 获取文档列表
- `POST /api/documents/parse` - 解析文档

### 搜索功能
- `POST /api/search/vector` - 向量搜索
- `POST /api/search/hybrid` - 混合搜索
- `POST /api/chat/search` - 聊天搜索

### LLM接口
- `POST /api/chat/completions` - 聊天完成
- `POST /api/chat/stream` - 流式聊天

## 🧪 测试

### 运行测试
```bash
# 运行所有测试
mvn test

# 运行特定测试
./test-rag-workflow.sh
./test-hybrid-search.sh
```

### 测试脚本
- `test-*.sh` - 各种功能测试脚本
- `run-rag-test.sh` - RAG工作流测试
- `test-integration.sh` - 集成测试

## 📈 性能优化

### 文档解析优化
- 异步解析处理
- 批量上传支持
- 进度跟踪机制

### 搜索性能
- 向量索引优化
- 缓存机制
- 分页查询

### 系统监控
- 健康检查端点
- 性能指标监控
- 日志分析

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证。

## 📞 联系方式

- **项目地址**：https://github.com/wuzhangyin/knowledgechain
- **问题反馈**：请通过GitHub Issues提交

---

**KnowledgeChain** - 让知识管理更智能！
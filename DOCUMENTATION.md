# Tài Liệu Dự Án: Juno - Ứng Dụng Quản Lý Dự Án B2B

## a. Mục đích chính và trường hợp sử dụng

Juno là một nền tảng quản lý dự án B2B hiện đại được xây dựng để giải quyết các vấn đề trong việc quản lý công việc nhóm và theo dõi tiến độ dự án. Ứng dụng này giải quyết những nhu cầu sau:

- **Quản lý công việc nhóm hiệu quả**: Cung cấp công cụ để các nhóm làm việc cùng nhau trong các dự án, giao nhiệm vụ, theo dõi tiến độ và quản lý thời hạn.
- **Phân quyền và kiểm soát truy cập**: Hệ thống phân quyền nâng cao cho phép các vai trò khác nhau (Owner, Administrator, Manager, Member) có quyền truy cập phù hợp với trách nhiệm của họ.
- **Tối ưu hóa quy trình làm việc**: Tự động hóa các quy trình như xác thực người dùng, quản lý dự án và phân quyền, giúp tiết kiệm thời gian và giảm thiểu lỗi.
- **Hỗ trợ đa workspace**: Cho phép người dùng quản lý nhiều workspace độc lập với các dự án, nhóm thành viên khác nhau.

## b. Lý do xây dựng ứng dụng

Lý do xây dựng ứng dụng này xuất phát từ nhu cầu thực tế của các nhóm làm việc trong môi trường doanh nghiệp cần một công cụ quản lý dự án linh hoạt, bảo mật và dễ sử dụng. Với sự phát triển của các nhóm làm việc từ xa và mô hình làm việc phân tán, cần một giải pháp giúp kết nối và tổ chức công việc hiệu quả hơn. Ngoài ra, việc xây dựng một nền tảng hoàn chỉnh giúp hiểu sâu hơn về kiến trúc full-stack hiện đại, hệ thống phân quyền phức tạp và quy trình DevOps.

## c. Thời gian và tiến độ thực hiện

**Thời gian bắt đầu**: Tháng 12 năm 2025  
**Thời gian hoàn thành**: Tháng 12 năm 2025  
**Tổng thời gian phát triển**: Khoảng 1-2 tuần làm việc tập trung

### Các giai đoạn phát triển:

1. **Giai đoạn lập kế hoạch (3-5 ngày)**: Xác định yêu cầu, thiết kế kiến trúc ứng dụng, chọn công nghệ
2. **Giai đoạn phát triển backend (1 tuần)**: Xây dựng API, hệ thống xác thực, mô hình dữ liệu, quản lý quyền
3. **Giai đoạn phát triển frontend (1 tuần)**: Xây dựng giao diện người dùng, tích hợp với API, xây dựng các thành phần UI
4. **Giai đoạn container hóa và triển khai (3-4 ngày)**: Cấu hình Docker, Kubernetes, CI/CD pipeline
5. **Giai đoạn kiểm thử và hoàn thiện (2-3 ngày)**: Kiểm thử chức năng, tối ưu hiệu suất, xử lý lỗi

## d. Đội ngũ phát triển

Dự án được thực hiện **một mình** bởi một lập trình viên Full-stack. Trong dự án này, người thực hiện đảm nhận tất cả các vai trò:

- **Lập trình viên Frontend**: Thiết kế giao diện người dùng, xây dựng các thành phần React
- **Lập trình viên Backend**: Xây dựng API, mô hình dữ liệu, hệ thống xác thực
- **DevOps Engineer**: Cấu hình Docker, Kubernetes, CI/CD pipeline
- **System Architect**: Thiết kế kiến trúc hệ thống, cơ sở dữ liệu, hệ thống phân quyền

## e. Các tính năng và luồng làm việc chính

### Tính năng chính:

1. **Xác thực người dùng**
   - Đăng ký/Đăng nhập bằng email
   - Đăng nhập bằng Google OAuth
   - Quản lý phiên làm việc

2. **Quản lý workspace**
   - Tạo và quản lý nhiều workspace
   - Chuyển đổi giữa các workspace
   - Cài đặt và cấu hình workspace

3. **Quản lý dự án**
   - Tạo, cập nhật, xóa dự án
   - Gán thành viên vào dự án
   - Theo dõi tiến độ dự án

4. **Quản lý tác vụ**
   - Tạo tác vụ với nhiều mức độ ưu tiên
   - Gán tác vụ cho thành viên
   - Cập nhật trạng thái tác vụ
   - Lọc và tìm kiếm tác vụ

5. **Hệ thống phân quyền**
   - Quản lý các vai trò khác nhau (Owner, Administrator, Manager, Member)
   - Phân quyền chi tiết theo chức năng
   - Kiểm tra quyền truy cập theo thời gian thực

6. **Triển khai hiện đại**
   - Container hóa bằng Docker
   - Orchestration bằng Kubernetes
   - CI/CD pipeline với GitHub Actions

### Luồng làm việc chính:

1. **Luồng xác thực**:
   - Người dùng đăng ký/login → Xác thực qua Google hoặc email → Tạo phiên → Truy cập workspace

2. **Luồng quản lý dự án**:
   - Tạo workspace → Mời thành viên → Tạo dự án → Gán tác vụ → Theo dõi tiến độ

3. **Luồng phân quyền**:
   - Gán role cho người dùng → Kiểm tra quyền theo thời gian thực → Áp dụng giới hạn chức năng

## f. Những gì học được và thách thức gặp phải

### Kỹ năng kỹ thuật học được:
- **Backend**: Xây dựng RESTful API với Node.js/Express, quản lý cơ sở dữ liệu MongoDB với Mongoose, triển khai hệ thống xác thực phức tạp
- **Frontend**: Phát triển giao diện hiện đại với React, quản lý trạng thái ứng dụng, tích hợp thư viện UI
- **DevOps**: Container hóa ứng dụng bằng Docker, triển khai lên Kubernetes, thiết lập CI/CD pipeline
- **Hệ thống phân quyền**: Thiết kế và triển khai hệ thống phân quyền phức tạp với nhiều cấp độ quyền

### Thách thức gặp phải:
- **Cấu hình Kubernetes**: Gặp khó khăn với việc cấu hình ingress, service, và deployment. Phải sửa lỗi liên quan đến tên container trong quá trình cập nhật image.
- **Proxy và routing**: Cấu hình Vite proxy để kết nối frontend và backend đúng cách trong môi trường phát triển.
- **Phân quyền phức tạp**: Thiết kế hệ thống phân quyền linh hoạt nhưng bảo mật và hiệu quả.
- **CI/CD pipeline**: Cấu hình GitHub Actions để tự động hóa quá trình build và deploy, xử lý các lỗi trong quá trình cập nhật deployment.
- **Deploy lên GKE**: Gặp nhiều thách thức khi triển khai lên Google Kubernetes Engine, bao gồm cấu hình dịch vụ, xác thực với GCP, và tối ưu hóa tài nguyên. Cần phải xử lý các lỗi liên quan đến quyền truy cập và cấu hình mạng.
- **Cân bằng chi phí**: Phải tối ưu hóa tài nguyên (CPU, memory) trong Kubernetes manifests để giảm chi phí vận hành trên GKE. Cấu hình tài nguyên yêu cầu và giới hạn phù hợp để đảm bảo hiệu suất trong khi kiểm soát chi phí.

### Kỹ năng mềm học được:
- **Quản lý dự án cá nhân**: Lên kế hoạch, ưu tiên các tính năng, quản lý thời gian hiệu quả
- **Giải quyết vấn đề**: Phân tích lỗi, tìm kiếm giải pháp, debug hệ thống phức tạp
- **Tự học**: Chủ động tìm hiểu công nghệ mới và áp dụng vào dự án

## g. Link repository

[https://github.com/nguyenhuyhieu261204/juno](https://github.com/nguyenhuyhieu261204/juno)

Repository chứa toàn bộ mã nguồn của ứng dụng, bao gồm cả frontend và backend, cấu hình Docker, Kubernetes manifests, và GitHub Actions workflow. Repository đã được cấu hình quyền truy cập công khai để dễ dàng xem xét mã nguồn.
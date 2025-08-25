import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../services/version_check_service.dart';

class VersionUpdateDialog extends StatefulWidget {
  final VersionInfo versionInfo;
  final VoidCallback? onCancel;

  const VersionUpdateDialog({
    super.key,
    required this.versionInfo,
    this.onCancel,
  });

  @override
  State<VersionUpdateDialog> createState() => _VersionUpdateDialogState();
}

class _VersionUpdateDialogState extends State<VersionUpdateDialog> {
  bool _isExpanded = false;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.versionInfo.forceUpdate,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Row(
                children: [
                  Icon(
                    Icons.system_update,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      FlutterI18n.translate(context, 'version.update.title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 版本信息
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          FlutterI18n.translate(context, 'version.update.current_version'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          widget.versionInfo.currentVersion,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          FlutterI18n.translate(context, 'version.update.latest_version'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.versionInfo.latestVersion,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Changelog
              if (widget.versionInfo.changelog.isNotEmpty) ...[
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              FlutterI18n.translate(context, 'version.update.changelog'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.versionInfo.changelog,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 升级类型提示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.versionInfo.forceUpdate
                      ? Colors.red[50]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.versionInfo.forceUpdate
                        ? Colors.red[200]!
                        : Colors.blue[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.versionInfo.forceUpdate
                          ? Icons.warning_amber
                          : Icons.info_outline,
                      color: widget.versionInfo.forceUpdate
                          ? Colors.red[600]
                          : Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.versionInfo.forceUpdate
                            ? FlutterI18n.translate(context, 'version.update.force_update_tip')
                            : FlutterI18n.translate(context, 'version.update.recommended_update_tip'),
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.versionInfo.forceUpdate
                              ? Colors.red[700]
                              : Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 按钮区域
              Row(
                children: [
                  // 取消按钮（仅推荐升级时显示）
                  if (!widget.versionInfo.forceUpdate) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          FlutterI18n.translate(context, 'common.cancel'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  // 下载按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDownloading ? null : _downloadUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isDownloading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  FlutterI18n.translate(context, 'version.update.downloading'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              FlutterI18n.translate(context, 'version.update.download'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadUpdate() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final success = await VersionCheckService().downloadUpdate(
        widget.versionInfo.downloadUrl,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                FlutterI18n.translate(context, 'version.update.download_started'),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                FlutterI18n.translate(context, 'version.update.download_failed'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              FlutterI18n.translate(context, 'version.update.download_error'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }
}

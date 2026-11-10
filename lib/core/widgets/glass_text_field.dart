import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';

/// Glassmorphic text input field with an 8 px radius.
///
/// Features a subtle glass backdrop, gold accent focus border, and error state
/// while reading all styling directly from [AppThemeTokens].
class GlassTextField extends ConsumerStatefulWidget {
  /// Creates a [GlassTextField].
  const GlassTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// An optional initial value.
  final String? initialValue;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// Optional label text displayed above the input.
  final String? labelText;

  /// Text that suggests what sort of input the field accepts.
  final String? hintText;

  /// Text that provides additional guidance below the input.
  final String? helperText;

  /// Text that indicates an error state.
  final String? errorText;

  /// An optional icon that appears before the prefix or text.
  final Widget? prefixIcon;

  /// An optional icon that appears after the text.
  final Widget? suffixIcon;

  /// Whether to hide the text being edited (e.g. for passwords).
  final bool obscureText;

  /// If false, text editing is disabled.
  final bool enabled;

  /// Whether this field should focus itself on initial render.
  final bool autofocus;

  /// The maximum number of lines for multiline input.
  final int? maxLines;

  /// The type of keyboard to display for editing the text.
  final TextInputType? keyboardType;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Called when the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates they are done editing the text.
  final ValueChanged<String>? onSubmitted;

  /// An optional method that checks the text against validation rules.
  final FormFieldValidator<String>? validator;

  @override
  ConsumerState<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends ConsumerState<GlassTextField> {
  late FocusNode _focusNode;
  bool _internalFocusNode = false;
  bool _isFocused = false;
  String? _fieldError;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _internalFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(GlassTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (_internalFocusNode) {
        _focusNode.removeListener(_handleFocusChange);
        _focusNode.dispose();
        _internalFocusNode = false;
      }
      if (widget.focusNode == null) {
        _focusNode = FocusNode();
        _internalFocusNode = true;
      } else {
        _focusNode = widget.focusNode!;
      }
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_internalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final radii = tokens.radii;
    final spacing = tokens.spacing;
    final durations = tokens.durations;
    final reduceEffects = ref.watch(reduceEffectsProvider);

    final effectiveError = widget.errorText ?? _fieldError;
    final hasError = effectiveError != null && effectiveError.isNotEmpty;

    // Compute dynamic border color
    final Color borderColor;
    if (hasError) {
      borderColor = colors.danger;
    } else if (_isFocused) {
      borderColor = colors.goldAccent;
    } else {
      borderColor = colors.glassBorder;
    }

    final fillColor = reduceEffects ? colors.glassFillSolid : colors.glassFill;

    final fieldRadius = radii.mdRadius;

    Widget inputContainer = AnimatedContainer(
      duration: durations.fast,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: fieldRadius,
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 1.5 : 1.0,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        style: tokens.textStyles.bodyMedium.copyWith(
          color: widget.enabled ? colors.textPrimary : colors.textMuted,
        ),
        cursorColor: colors.goldAccent,
        onChanged: (value) {
          if (_fieldError != null) {
            setState(() => _fieldError = null);
          }
          widget.onChanged?.call(value);
        },
        onFieldSubmitted: widget.onSubmitted,
        validator: (value) {
          final error = widget.validator?.call(value);
          if (error != _fieldError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _fieldError = error);
              }
            });
          }
          return error;
        },
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.md,
          ),
          hintText: widget.hintText,
          hintStyle: tokens.textStyles.bodyMedium.copyWith(
            color: colors.textMuted,
          ),
          prefixIcon: widget.prefixIcon != null
              ? IconTheme(
                  data: IconThemeData(
                    color:
                        _isFocused ? colors.goldAccent : colors.textSecondary,
                    size: 20,
                  ),
                  child: widget.prefixIcon!,
                )
              : null,
          suffixIcon: widget.suffixIcon != null
              ? IconTheme(
                  data: IconThemeData(
                    color:
                        _isFocused ? colors.goldAccent : colors.textSecondary,
                    size: 20,
                  ),
                  child: widget.suffixIcon!,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          // Suppress default error rendering since we custom render it below
          errorStyle: const TextStyle(fontSize: 0, height: 0),
        ),
      ),
    );

    if (reduceEffects) {
      inputContainer = ClipRRect(
        borderRadius: fieldRadius,
        child: inputContainer,
      );
    } else {
      inputContainer = ClipRRect(
        borderRadius: fieldRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: inputContainer,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: tokens.textStyles.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spacing.xs),
        ],
        inputContainer,
        if (hasError) ...[
          SizedBox(height: spacing.xs),
          Text(
            effectiveError,
            style: tokens.textStyles.bodySmall.copyWith(
              color: colors.danger,
            ),
          ),
        ] else if (widget.helperText != null) ...[
          SizedBox(height: spacing.xs),
          Text(
            widget.helperText!,
            style: tokens.textStyles.bodySmall.copyWith(
              color: colors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

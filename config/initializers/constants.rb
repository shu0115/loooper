# coding: utf-8

# OmniAuth Provider
# Production環境
if Rails.env.production?
  DEFAULT_PROVIDER = "twitter"
  # DEFAULT_PROVIDER = "facebook"
  # DEFAULT_PROVIDER = "github"

# Production環境以外
else
  # DEFAULT_PROVIDER = "developer"
  DEFAULT_PROVIDER = "twitter"
  # DEFAULT_PROVIDER = "facebook"
  # DEFAULT_PROVIDER = "github"
end

# アプリケーション名
APP_NAME = "Loooper"

# プログラマ名
PROGRAMMER_NAME = "shu_0115"

# デザイナー名
DESIGNER_NAME = "machida"

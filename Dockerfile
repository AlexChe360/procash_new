# Базовое изображение с Ruby и Node.js
FROM ruby:3.3.1

# Устанавливаем зависимости для PostgreSQL, Yarn, Node.js и т.д.
RUN apt-get update -qq && apt-get install -y nodejs yarn

# Устанавливаем рабочую директорию в контейнере
WORKDIR /app

# Копируем файл Gemfile и Gemfile.lock для установки зависимостей
COPY Gemfile Gemfile.lock /app/

# Устанавливаем зависимости через Bundler
RUN bundle install

# Копируем остальные файлы приложения
COPY . /app/

# Предварительно компилируем ассеты для production
RUN bundle exec rails assets:precompile

# Открываем порт для сервера
EXPOSE 3000

# Команда для запуска Puma сервера
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

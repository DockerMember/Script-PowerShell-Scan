# Параметры скрипта
$FolderName = "Scan"
$UserName = "Scaner"
$Password = "Parabola-694"
$ShareName = "Scan"
$FolderPath = "C:\$FolderName"
$ComputerName = $env:COMPUTERNAME

# 1. Создание папки
if (!(Test-Path -Path $FolderPath)) {
    New-Item -ItemType Directory -Path $FolderPath
} else {
    Write-Host "Папка '$FolderName' уже существует."
}

# 2. Создание локального пользователя
try {
    # Преобразуем пароль в SecureString
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    # Создаем пользователя
    New-LocalUser -Name $UserName -Password $SecurePassword

    # Устанавливаем "срок действия пароля не ограничен"
    Set-LocalUser -Name $UserName -PasswordNeverExpires $true
}
catch {
    Write-Host "Ошибка при создании пользователя: $($_.Exception.Message)"
}

# 3. Создание общего ресурса и настройка разрешений
try {
    # Удаляем существующий общий ресурс (если есть)
    Remove-SmbShare -Name $ShareName -Force -ErrorAction SilentlyContinue

    # Создаем общий ресурс без разрешений (только для администратора)
    New-SmbShare -Name $ShareName -Path $FolderPath

    # Предоставляем пользователю Scaner полные права
    $AccountName = "$ComputerName\$UserName" # Формируем имя учетной записи
    Grant-SmbShareAccess -Name $ShareName -AccountName $AccountName -AccessRight Full

}
catch {
    Write-Host "Ошибка при создании общего ресурса: $($_.Exception.Message)"
}

Write-Host "Скрипт выполнен успешно."
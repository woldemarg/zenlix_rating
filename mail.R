library(readr)
library(stringr)
library(rjson)
library(mailR)


#===basic settings===#
setwd("D:/OneDrive/myRepos/zenlix_rating") #рабочая директория

zDmin <- read_lines("../etpp.txt") #скрытые параметры
interval <- 25


json <- rjson::fromJSON(file = zDmin[13])
Sys.sleep(interval)

# http://mkseo.pe.kr/stats/?p=898
list <- as.data.frame(do.call(rbind, json))


if (nrow(list) == 0) {
  cat("No tickets to rate")
} else {
  for (row in 1:nrow(list)) {
    # жестко забиваем в форму некоторые поля,
    # необходимые для идентификации заявки
    # при переносе в БД на сервере
    email <- list$client_email[row]
    ticket <- list$ticket_id[row]
    name <- list$client_name[row]
    subj <- list$ticket_subject[row]
    tkt_date <- list$ok_date[row]
    expert <- list$expert_name[row]
    
    # делаем все "жесткие" поля одинаковой ширины
    size <-
      max(str_length(name), str_length(expert), str_length(subj))
    
    # формируем хтмл файл по частям, т.к. при автоматическом
    # запуске скрипта из .bat возникают проблемы с кодировкой
    # https://github.com/rpremraj/mailR/issues/60
    html <- read.csv("html_letter.csv",
                     encoding = "UTF-8",
                     stringsAsFactors = FALSE)
    
    send.mail(
      from = zDmin[10],
      to = email,
      replyTo = c(zDmin[11]),
      subject = paste(html$p0, ticket, sep = ""),
      body = paste(
        html$p1,
        zDmin[14],
        html$p2,
        size,
        html$p3,
        name,
        html$p4,
        size,
        html$p5,
        ticket,
        html$p6,
        size,
        html$p7,
        subj,
        html$p8,
        size,
        html$p9,
        tkt_date,
        html$p10,
        size,
        html$p11,
        expert,
        html$p12,
        sep = ""
      ),
      html = TRUE,
      encoding = "utf-8",
      smtp = list(
        host.name = "smtp.gmail.com",
        port = 465,
        user.name = zDmin[12],
        passwd = zDmin[5],
        ssl = TRUE
      ),
      authenticate = TRUE,
      send = TRUE
    )
    
    Sys.sleep(interval)
  }
}

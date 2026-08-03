//
//  AiDefaultErrorMessageProvider.m
//  AiSDK
//
//  Created by HuaWo on 2025/7/31.
//

#import "AiDefaultErrorMessageProvider.h"

@implementation AiDefaultErrorMessageProvider

- (NSString *)messageForCode:(NSInteger)code
{
    if (self.deviceLanguageCode < 0) {
        return nil;
    }
    return [self getErrorMessageWithLanguage:self.deviceLanguageCode errorCode:code];
}

- (NSString *)getErrorMessageWithLanguage:(NSInteger)language errorCode:(NSInteger)errorCode {
    switch(language) {
        case 0:{
            // English
            switch (errorCode) {
                case 1: return @"Server error 1";
                case 2: return @"Server error 2";
                case 3: return @"Server error 3";
                case 4: return @"Identification is empty";
                case 5: return @"Request parameter error";
                case 6: return @"TTS is not supported";
                case 7: return @"STT is not supported";
                case 8: return @"Insufficient times";
                case 9: return @"Today's free times have been used up";
                case 10: return @"Free times have been used up";
                case 11: return @"Paid function";
                case 12: return @"Sensitive words involved, please try again";
                case 13: return @"Please use a language supported by the watch";
                case 14: return @"Generating";
                case 18: return @"Meeting creation failed";
                case 19: return @"Health analysis failed";
                case 20: return @"Binding limit reached";
                case 50: return @"Server error 4";
                case 61: return @"User verification failed";
                case 1101: return @"Request timeout";
                case 1102: return @"Unable to access server";
                case 1103: return @"Unknown error";
                case 1104: return @"File upload failed";
                case 80002: return @"There is no sound";
                default: return nil;
            }
            break;
        }
        case 0x01: {
            // Simplified Chinese
            switch (errorCode) {
                case 1: return @"服务器错误1";
                case 2: return @"服务器错误2";
                case 3: return @"服务器错误3";
                case 4: return @"识别为空";
                case 5: return @"请求参数错误";
                case 6: return @"不支持tts";
                case 7: return @"不支持stt";
                case 8: return @"次数不足";
                case 9: return @"今日免费次数已用完";
                case 10: return @"免费次数已用完";
                case 11: return @"付费功能";
                case 12: return @"涉及敏感词，请重试";
                case 13: return @"请使用手表支持的语言";
                case 14: return @"生成中";
                case 18: return @"会议生成失败";
                case 19: return @"健康分析失败";
                case 20: return @"绑定已达上限";
                case 50: return @"服务器错误4";
                case 61: return @"用户验证失败";
                case 1101: return @"请求超时";
                case 1102: return @"无法访问服务器";
                case 1103: return @"未知错误";
                case 1104: return @"文件上传失败";
                case 80002: return @"没有声音";
                default: return nil;
            }
            break;
        }
        case 0x02: {
            // Traditional Chinese
            switch (errorCode) {
                case 1: return @"服務器錯誤1";
                case 2: return @"服務器錯誤2";
                case 3: return @"服務器錯誤3";
                case 4: return @"識別為空";
                case 5: return @"請求參數錯誤";
                case 6: return @"不支持tts";
                case 7: return @"不支持stt";
                case 8: return @"次數不足";
                case 9: return @"今日免費次數已用完";
                case 10: return @"免費次數已用完";
                case 11: return @"付費功能";
                case 12: return @"涉及敏感詞，請重試";
                case 13: return @"請使用手錶支持的語言";
                case 14: return @"生成中";
                case 18: return @"會議生成失敗";
                case 19: return @"健康分析失敗";
                case 20: return @"綁定已達上限";
                case 50: return @"服務器錯誤4";
                case 61: return @"用戶驗證失敗";
                case 1101: return @"請求超時";
                case 1102: return @"無法訪問服務器";
                case 1103: return @"未知錯誤";
                case 1104: return @"文件上傳失敗";
                case 80002: return @"沒有聲音";
                default: return nil;
            }
            break;
        }
        case 0x03: {
            // Korean
            switch (errorCode) {
                case 1: return @"서버 오류 1";
                case 2: return @"서버 오류 2";
                case 3: return @"서버 오류 3";
                case 4: return @"ID가 비어 있습니다.";
                case 5: return @"요청 매개변수 오류";
                case 6: return @"TTS가 지원되지 않습니다.";
                case 7: return @"STT가 지원되지 않습니다.";
                case 8: return @"시간 부족";
                case 9: return @"오늘의 무료 시간이 모두 소진되었습니다.";
                case 10: return @"무료 시간이 모두 소진되었습니다.";
                case 11: return @"유료 기능";
                case 12: return @"민감한 단어가 포함되어 있습니다. 다시 시도해 주세요.";
                case 13: return @"시계에서 지원하는 언어를 사용하세요.";
                case 14: return @"생성 중";
                case 18: return @"회의 생성에 실패했습니다.";
                case 19: return @"상태 분석 실패";
                case 20: return @"바인딩 한도 도달";
                case 50: return @"서버 오류 4";
                case 61: return @"사용자 확인 실패";
                case 1101: return @"요청 시간 초과";
                case 1102: return @"서버에 액세스할 수 없습니다.";
                case 1103: return @"알 수 없는 오류";
                case 1104: return @"파일 업로드 실패";
                case 80002: return @"소리가 없습니다";
                default: return nil;
            }
            break;
        }
        case 0x04: {// Thai
            switch (errorCode) {
                case 1: return @"ข้อผิดพลาดเซิร์ฟเวอร์ 1";
                case 2: return @"ข้อผิดพลาดเซิร์ฟเวอร์ 2";
                case 3: return @"ข้อผิดพลาดเซิร์ฟเวอร์ 3";
                case 4: return @"การระบุตัวตนว่างเปล่า";
                case 5: return @"ข้อผิดพลาดพารามิเตอร์คำขอ";
                case 6: return @"ไม่รองรับ TTS";
                case 7: return @"ไม่รองรับ STT";
                case 8: return @"เวลาไม่เพียงพอ";
                case 9: return @"เวลาว่างของวันนี้หมดลงแล้ว";
                case 10: return @"เวลาว่างหมดลงแล้ว";
                case 11: return @"ฟังก์ชันแบบชำระเงิน";
                case 12: return @"มีคำที่ละเอียดอ่อน โปรดลองอีกครั้ง";
                case 13: return @"โปรดใช้ภาษาที่นาฬิการองรับ";
                case 14: return @"กำลังสร้าง";
                case 18: return @"การสร้างการประชุมล้มเหลว";
                case 19: return @"การวิเคราะห์สถานะล้มเหลว";
                case 20: return @"ถึงขีดจำกัดการผูกแล้ว";
                case 50: return @"ข้อผิดพลาดเซิร์ฟเวอร์ 4";
                case 61: return @"การตรวจสอบผู้ใช้ล้มเหลว";
                case 1101: return @"หมดเวลาคำขอ";
                case 1102: return @"ไม่สามารถเข้าถึงเซิร์ฟเวอร์ได้";
                case 1103: return @"ข้อผิดพลาดที่ไม่รู้จัก";
                case 1104: return @"การอัปโหลดไฟล์ล้มเหลว";
                case 80002: return @"ไม่มีเสียง";
                default: return nil;
            }
            break;
        }
        case 0x05: {// Japanese
            switch (errorCode) {
                case 1: return @"サーバーエラー 1";
                case 2: return @"サーバーエラー 2";
                case 3: return @"サーバーエラー 3";
                case 4: return @"IDが空です";
                case 5: return @"リクエストパラメータエラー";
                case 6: return @"TTSはサポートされていません";
                case 7: return @"STTはサポートされていません";
                case 8: return @"回数が足りません";
                case 9: return @"本日の無料回数を使い切りました";
                case 10: return @"無料回数を使い切りました";
                case 11: return @"有料機能";
                case 12: return @"センシティブな言葉が含まれています。もう一度お試しください";
                case 13: return @"ウォッチがサポートしている言語を使用してください";
                case 14: return @"生成中";
                case 18: return @"会議の作成に失敗しました";
                case 19: return @"ヘルス分析に失敗しました";
                case 20: return @"バインド制限に達しました";
                case 50: return @"サーバーエラー 4";
                case 61: return @"ユーザー認証に失敗しました";
                case 1101: return @"リクエストがタイムアウトしました";
                case 1102: return @"サーバーにアクセスできません";
                case 1103: return @"不明なエラー";
                case 1104: return @"ファイルのアップロードに失敗しました";
                case 80002: return @"音はありません";
                default: return nil;
            }
            break;
        }
        case 0x06: {// Spanish
            switch (errorCode) {
                case 1: return @"Error de servidor 1";
                case 2: return @"Error de servidor 2";
                case 3: return @"Error de servidor 3";
                case 4: return @"Identificación vacía";
                case 5: return @"Error en el parámetro de solicitud";
                case 6: return @"TTS no compatible";
                case 7: return @"STT no compatible";
                case 8: return @"Tiempo insuficiente";
                case 9: return @"Se han agotado los tiempos libres de hoy";
                case 10: return @"Se han agotado los tiempos libres";
                case 11: return @"Función de pago";
                case 12: return @"Se han utilizado palabras sensibles; inténtalo de nuevo";
                case 13: return @"Utiliza un idioma compatible con el reloj";
                case 14: return @"Generando";
                case 18: return @"Error en la creación de la reunión";
                case 19: return @"Error en el análisis de salud";
                case 20: return @"Límite de vinculación alcanzado";
                case 50: return @"Error de servidor 4";
                case 61: return @"Error en la verificación del usuario";
                case 1101: return @"Tiempo de espera agotado";
                case 1102: return @"No se puede acceder al servidor";
                case 1103: return @"Error desconocido";
                case 1104: return @"Error al subir el archivo";
                case 80002: return @"No hay sonido";
                default: return nil;
            }
            break;
        }
        case 0x07: {// French
            switch (errorCode) {
                case 1: return @"Erreur serveur 1";
                case 2: return @"Erreur serveur 2";
                case 3: return @"Erreur serveur 3";
                case 4: return @"Identification vide";
                case 5: return @"Erreur de paramètre de requête";
                case 6: return @"TTS non pris en charge";
                case 7: return @"STT non pris en charge";
                case 8: return @"Temps insuffisants";
                case 9: return @"Temps gratuits du jour épuisés";
                case 10: return @"Temps gratuits épuisés";
                case 11: return @"Fonction payante";
                case 12: return @"Mots sensibles impliqués, veuillez réessayer";
                case 13: return @"Veuillez utiliser une langue prise en charge par la montre";
                case 14: return @"Génération";
                case 18: return @"La création de la réunion a échoué";
                case 19: return @"Échec de l'analyse de santé";
                case 20: return @"Limite de liaison atteinte";
                case 50: return @"Erreur serveur 4";
                case 61: return @"Échec de la vérification de l'utilisateur";
                case 1101: return @"Délai de requête expiré";
                case 1102: return @"Impossible d'accéder au serveur";
                case 1103: return @"Erreur inconnue";
                case 1104: return @"Échec du téléchargement du fichier";
                case 80002: return @"Il n'y a pas de son";
                default: return nil;
            }
            break;
        }
        case 0x08: {// German
            switch (errorCode) {
                case 1: return @"Serverfehler 1";
                case 2: return @"Serverfehler 2";
                case 3: return @"Serverfehler 3";
                case 4: return @"Kennung ist leer";
                case 5: return @"Anforderungsparameterfehler";
                case 6: return @"TTS wird nicht unterstützt";
                case 7: return @"STT wird nicht unterstützt";
                case 8: return @"Nicht genügend Zeit";
                case 9: return @"Heutige Freizeiten sind aufgebraucht";
                case 10: return @"Freizeiten sind aufgebraucht";
                case 11: return @"Kostenpflichtige Funktion";
                case 12: return @"Sensible Wörter enthalten, bitte versuchen Sie es erneut";
                case 13: return @"Bitte verwenden Sie eine von der Uhr unterstützte Sprache";
                case 14: return @"Erstellung läuft";
                case 18: return @"Fehler beim Erstellen des Meetings";
                case 19: return @"Gesundheitsanalyse fehlgeschlagen";
                case 20: return @"Bindungslimit erreicht";
                case 50: return @"Serverfehler 4";
                case 61: return @"Benutzerverifizierung fehlgeschlagen";
                case 1101: return @"Anforderungstimeout";
                case 1102: return @"Kein Zugriff auf den Server möglich";
                case 1103: return @"Unbekannter Fehler";
                case 1104: return @"Dateiupload fehlgeschlagen";
                case 80002: return @"Es gibt keinen Ton";
                default: return nil;
            }
            break;
        }
        case 0x09: {// Italian
            switch (errorCode) {
                case 1: return @"Errore del server 1";
                case 2: return @"Errore del server 2";
                case 3: return @"Errore del server 3";
                case 4: return @"Identificazione vuota";
                case 5: return @"Errore nel parametro di richiesta";
                case 6: return @"TTS non supportato";
                case 7: return @"STT non supportato";
                case 8: return @"Tempi insufficienti";
                case 9: return @"Tempi gratuiti odierni esauriti";
                case 10: return @"Tempi gratuiti esauriti";
                case 11: return @"Funzione a pagamento";
                case 12: return @"Parole sensibili coinvolte, riprovare";
                case 13: return @"Utilizzare una lingua supportata dall'orologio";
                case 14: return @"Generazione in corso";
                case 18: return @"Creazione della riunione non riuscita";
                case 19: return @"Analisi dello stato di integrità non riuscita";
                case 20: return @"Limite di binding raggiunto";
                case 50: return @"Errore del server 4";
                case 61: return @"Verifica utente non riuscita";
                case 1101: return @"Timeout della richiesta";
                case 1102: return @"Impossibile accedere al server";
                case 1103: return @"Errore sconosciuto";
                case 1104: return @"Caricamento del file non riuscito";
                case 80002: return @"Non c'è suono";
                default: return nil;
            }
            break;
        }
        case 0x0a: {// Polish
            switch (errorCode) {
                case 1: return @"Błąd serwera 1";
                case 2: return @"Błąd serwera 2";
                case 3: return @"Błąd serwera 3";
                case 4: return @"Identyfikator jest pusty";
                case 5: return @"Błąd parametru żądania";
                case 6: return @"TTS nie jest obsługiwany";
                case 7: return @"STT nie jest obsługiwany";
                case 8: return @"Za mało czasu";
                case 9: return @"Dzisiejszy bezpłatny czas został wykorzystany";
                case 10: return @"Bezpłatny czas został wykorzystany";
                case 11: return @"Funkcja płatna";
                case 12: return @"Zawarte są słowa wrażliwe, spróbuj ponownie";
                case 13: return @"Użyj języka obsługiwanego przez zegarek";
                case 14: return @"Generowanie";
                case 18: return @"Nie udało się utworzyć spotkania";
                case 19: return @"Analiza stanu nie powiodła się";
                case 20: return @"Osiągnięto limit powiązań";
                case 50: return @"Błąd serwera 4";
                case 61: return @"Weryfikacja użytkownika nie powiodła się";
                case 1101: return @"Przekroczono limit czasu żądania";
                case 1102: return @"Brak dostępu do serwera";
                case 1103: return @"Nieznany błąd";
                case 1104: return @"Nie udało się przesłać pliku";
                case 80002: return @"Nie ma dźwięku";
                default: return nil;
            }
            break;
        }
        case 0x0b: {// Portuguese
            switch (errorCode) {
                case 1: return @"Erro de servidor 1";
                case 2: return @"Erro de servidor 2";
                case 3: return @"Erro de servidor 3";
                case 4: return @"A identificação está vazia";
                case 5: return @"Erro de parâmetro de pedido";
                case 6: return @"O TTS não é suportado";
                case 7: return @"O STT não é suportado";
                case 8: return @"Tempos insuficientes";
                case 9: return @"Os tempos livres de hoje foram esgotados";
                case 10: return @"Os tempos livres foram esgotados";
                case 11: return @"Função paga";
                case 12: return @"Palavras sensíveis envolvidas, tente novamente";
                case 13: return @"Por favor, utilize um idioma suportado pelo relógio";
                case 14: return @"Gerando";
                case 18: return @"Falha na criação da reunião";
                case 19: return @"A análise de saúde falhou";
                case 20: return @"Limite de vinculação atingido";
                case 50: return @"Erro de servidor 4";
                case 61: return @"Falha na verificação do utilizador";
                case 1101: return @"Tempo limite da solicitação";
                case 1102: return @"Não é possível aceder ao servidor";
                case 1103: return @"Erro desconhecido";
                case 1104: return @"Falha no upload do ficheiro";
                case 80002: return @"Não há som";
                default: return nil;
            }
            break;
        }
        case 0x0c: {// Russian
            switch (errorCode) {
                case 1: return @"Ошибка сервера 1";
                case 2: return @"Ошибка сервера 2";
                case 3: return @"Ошибка сервера 3";
                case 4: return @"Идентификатор пуст";
                case 5: return @"Ошибка параметра запроса";
                case 6: return @"TTS не поддерживается";
                case 7: return @"STT не поддерживается";
                case 8: return @"Недостаточно времени";
                case 9: return @"Сегодняшнее бесплатное время использовано";
                case 10: return @"Бесплатное время использовано";
                case 11: return @"Платная функция";
                case 12: return @"Использованы деликатные слова, попробуйте ещё раз";
                case 13: return @"Используйте язык, поддерживаемый часами";
                case 14: return @"Генерация";
                case 18: return @"Не удалось создать встречу";
                case 19: return @"Ошибка анализа работоспособности";
                case 20: return @"Достигнут лимит привязки";
                case 50: return @"Ошибка сервера 4";
                case 61: return @"Ошибка проверки пользователя";
                case 1101: return @"Время ожидания запроса истекло";
                case 1102: return @"Невозможно получить доступ к серверу";
                case 1103: return @"Неизвестная ошибка";
                case 1104: return @"Ошибка загрузки файла";
                case 80002: return @"Нет звука";
                default: return nil;
            }
            break;
        }
        case 0x0d: {// Dutch
            switch (errorCode) {
                case 1: return @"Serverfout 1";
                case 2: return @"Serverfout 2";
                case 3: return @"Serverfout 3";
                case 4: return @"Identificatie is leeg";
                case 5: return @"Fout in aanvraagparameter";
                case 6: return @"TTS wordt niet ondersteund";
                case 7: return @"STT wordt niet ondersteund";
                case 8: return @"Onvoldoende tijd";
                case 9: return @"De gratis tijd van vandaag is opgebruikt";
                case 10: return @"Gratis tijd is opgebruikt";
                case 11: return @"Betaalde functie";
                case 12: return @"Gevoelige woorden betrokken, probeer het opnieuw";
                case 13: return @"Gebruik een taal die door het horloge wordt ondersteund";
                case 14: return @"Genereren";
                case 18: return @"Vergadering aanmaken mislukt";
                case 19: return @"Gezondheidsanalyse mislukt";
                case 20: return @"Bindingslimiet bereikt";
                case 50: return @"Serverfout 4";
                case 61: return @"Gebruikersverificatie mislukt";
                case 1101: return @"Time-out aanvraag";
                case 1102: return @"Kan geen toegang krijgen tot de server";
                case 1103: return @"Onbekende fout";
                case 1104: return @"Bestand uploaden mislukt";
                case 80002: return @"Er is geen geluid";
                default: return nil;
            }
            break;
        }
        case 0x0e: {// Arabic
            switch (errorCode) {
                case 1: return @"خطأ في الخادم ١";
                case 2: return @"خطأ في الخادم ٢";
                case 3: return @"خطأ في الخادم ٣";
                case 4: return @"التعريف فارغ";
                case 5: return @"خطأ في معلمة الطلب";
                case 6: return @"تحويل النص إلى كلام غير مدعوم";
                case 7: return @"تحويل النص إلى كلام غير مدعوم";
                case 8: return @"عدد مرات غير كاف";
                case 9: return @"تم استنفاد الأوقات المجانية لهذا اليوم";
                case 10: return @"تم استنفاد الأوقات المجانية";
                case 11: return @"وظيفة مدفوعة";
                case 12: return @"كلمات حساسة متضمنة، يُرجى المحاولة مرة أخرى";
                case 13: return @"يرجى استخدام لغة تدعمها الساعة";
                case 14: return @"جاري التوليد";
                case 18: return @"فشل إنشاء الاجتماع";
                case 19: return @"فشل تحليل الحالة";
                case 20: return @"تم الوصول إلى حد الربط";
                case 50: return @"خطأ في الخادم ٤";
                case 61: return @"فشل التحقق من المستخدم";
                case 1101: return @"انتهت مهلة الطلب";
                case 1102: return @"تعذر الوصول إلى الخادم";
                case 1103: return @"خطأ غير معروف";
                case 1104: return @"فشل تحميل الملف";
                case 80002: return @"لا يوجد صوت";
                default: return nil;
            }
            break;
        }
        case 0x11: {// Hebrew
            switch (errorCode) {
                case 1: return @"שגיאת שרת 1";
                case 2: return @"שגיאת שרת 2";
                case 3: return @"שגיאת שרת 3";
                case 4: return @"זיהוי ריק";
                case 5: return @"שגיאת פרמטר בקשה";
                case 6: return @"TTS אינו נתמך";
                case 7: return @"STT אינו נתמך";
                case 8: return @"זמנים לא מספיקים";
                case 9: return @"הזמנים הפנויים של היום נוצלו";
                case 10: return @"הזמנים הפנויים נוצלו";
                case 11: return @"פונקציה בתשלום";
                case 12: return @"מילים רגישות מעורבות, אנא נסה שוב";
                case 13: return @"אנא השתמש בשפה הנתמכת על ידי השעון";
                case 14: return @"יוצר";
                case 18: return @"יצירת הפגישה נכשלה";
                case 19: return @"ניתוח תקינות נכשל";
                case 20: return @"מגבלת קישור הגיעה";
                case 50: return @"שגיאת שרת 4";
                case 61: return @"אימות משתמש נכשל";
                case 1101: return @"פסק זמן של בקשה";
                case 1102: return @"לא ניתן לגשת לשרת";
                case 1103: return @"שגיאה לא ידועה";
                case 1104: return @"העלאת קובץ נכשלה";
                case 80002: return @"אין צליל";
                default: return nil;
            }
            break;
        }
        case 0x13: {// Czech
            switch (errorCode) {
                case 1: return @"Chyba serveru 1";
                case 2: return @"Chyba serveru 2";
                case 3: return @"Chyba serveru 3";
                case 4: return @"Identifikace je prázdná";
                case 5: return @"Chyba parametru požadavku";
                case 6: return @"TTS není podporováno";
                case 7: return @"STT není podporováno";
                case 8: return @"Nedostatek časů";
                case 9: return @"Dnešní volné časy byly vyčerpány";
                case 10: return @"Volné časy byly vyčerpány";
                case 11: return @"Placená funkce";
                case 12: return @"Obsahuje citlivá slova, zkuste to prosím znovu";
                case 13: return @"Použijte jazyk podporovaný hodinkami";
                case 14: return @"Generování";
                case 18: return @"Vytvoření schůzky se nezdařilo";
                case 19: return @"Analýza stavu selhala";
                case 20: return @"Dosažen limit vazeb";
                case 50: return @"Chyba serveru 4";
                case 61: return @"Ověření uživatele selhalo";
                case 1101: return @"Časový limit požadavku";
                case 1102: return @"Nelze přistupovat k serveru";
                case 1103: return @"Neznámá chyba";
                case 1104: return @"Nahrávání souboru selhalo";
                case 80002: return @"Neexistuje žádný zvuk";
                default: return nil;
            }
            break;
        }
        case 0x22: {// Hindi
            switch (errorCode) {
                case 1: return @"सर्वर त्रुटि 1";
                case 2: return @"सर्वर त्रुटि 2";
                case 3: return @"सर्वर त्रुटि 3";
                case 4: return @"पहचान रिक्त है";
                case 5: return @"अनुरोध पैरामीटर त्रुटि";
                case 6: return @"TTS समर्थित नहीं है";
                case 7: return @"STT समर्थित नहीं है";
                case 8: return @"अपर्याप्त समय";
                case 9: return @"आज का खाली समय समाप्त हो गया है";
                case 10: return @"खाली समय समाप्त हो गया है";
                case 11: return @"भुगतान किया गया फ़ंक्शन";
                case 12: return @"संवेदनशील शब्द शामिल हैं, कृपया पुनः प्रयास करें";
                case 13: return @"कृपया घड़ी द्वारा समर्थित भाषा का उपयोग करें";
                case 14: return @"जनरेट हो रहा है";
                case 18: return @"मीटिंग निर्माण विफल";
                case 19: return @"स्वास्थ्य विश्लेषण विफल";
                case 20: return @"बाइंडिंग सीमा पूरी हो गई";
                case 50: return @"सर्वर त्रुटि 4";
                case 61: return @"उपयोगकर्ता सत्यापन विफल";
                case 1101: return @"अनुरोध समय समाप्त";
                case 1102: return @"सर्वर तक पहुँचने में असमर्थ";
                case 1103: return @"अज्ञात त्रुटि";
                case 1104: return @"फ़ाइल अपलोड विफल";
                case 80002: return @"कोई आवाज नहीं है";
                default: return nil;
            }
            break;
        }
        case 0x23: {// Vietnamese
            switch (errorCode) {
                case 1: return @"Lỗi máy chủ 1";
                case 2: return @"Lỗi máy chủ 2";
                case 3: return @"Lỗi máy chủ 3";
                case 4: return @"Nhận dạng trống";
                case 5: return @"Lỗi tham số yêu cầu";
                case 6: return @"TTS không được hỗ trợ";
                case 7: return @"STT không được hỗ trợ";
                case 8: return @"Không đủ thời gian";
                case 9: return @"Đã sử dụng hết thời gian rảnh hôm nay";
                case 10: return @"Đã sử dụng hết thời gian rảnh";
                case 11: return @"Chức năng trả phí";
                case 12: return @"Có từ ngữ nhạy cảm, vui lòng thử lại";
                case 13: return @"Vui lòng sử dụng ngôn ngữ được đồng hồ hỗ trợ";
                case 14: return @"Đang tạo";
                case 18: return @"Không tạo được cuộc họp";
                case 19: return @"Phân tích tình trạng không thành công";
                case 20: return @"Đạt giới hạn liên kết";
                case 50: return @"Lỗi máy chủ 4";
                case 61: return @"Xác minh người dùng không thành công";
                case 1101: return @"Hết thời gian yêu cầu";
                case 1102: return @"Không thể truy cập máy chủ";
                case 1103: return @"Lỗi không xác định";
                case 1104: return @"Tải tệp lên không thành công";
                case 80002: return @"Không có âm thanh";
                default: return nil;
            }
            break;
        }
        case 0x24: {// Indonesian
            switch (errorCode) {
                case 1: return @"Kesalahan server 1";
                case 2: return @"Kesalahan server 2";
                case 3: return @"Kesalahan server 3";
                case 4: return @"Identifikasi kosong";
                case 5: return @"Kesalahan parameter permintaan";
                case 6: return @"TTS tidak didukung";
                case 7: return @"STT tidak didukung";
                case 8: return @"Waktu tidak mencukupi";
                case 9: return @"Waktu luang hari ini telah habis";
                case 10: return @"Waktu luang telah habis";
                case 11: return @"Fungsi berbayar";
                case 12: return @"Terdapat kata-kata sensitif, silakan coba lagi";
                case 13: return @"Harap gunakan bahasa yang didukung oleh jam tangan";
                case 14: return @"Membuat";
                case 18: return @"Pembuatan rapat gagal";
                case 19: return @"Analisis kesehatan gagal";
                case 20: return @"Batas pengikatan tercapai";
                case 50: return @"Kesalahan server 4";
                case 61: return @"Verifikasi pengguna gagal";
                case 1101: return @"Waktu permintaan habis";
                case 1102: return @"Tidak dapat mengakses server";
                case 1103: return @"Kesalahan tidak diketahui";
                case 1104: return @"Unggahan berkas gagal";
                case 80002: return @"Tidak ada suara";
                default: return nil;
            }
            break;
        }
        case 0x25: {// Turkish
            switch (errorCode) {
                case 1: return @"Sunucu hatası 1";
                case 2: return @"Sunucu hatası 2";
                case 3: return @"Sunucu hatası 3";
                case 4: return @"Kimlik boş";
                case 5: return @"İstek parametresi hatası";
                case 6: return @"TTS desteklenmiyor";
                case 7: return @"STT desteklenmiyor";
                case 8: return @"Yetersiz süre";
                case 9: return @"Bugünün boş süreleri tükendi";
                case 10: return @"Boş süreleri tükendi";
                case 11: return @"Ücretli işlev";
                case 12: return @"Hassas kelimeler içeriyor, lütfen tekrar deneyin";
                case 13: return @"Lütfen saat tarafından desteklenen bir dil kullanın";
                case 14: return @"Oluşturuluyor";
                case 18: return @"Toplantı oluşturma başarısız oldu";
                case 19: return @"Sağlık analizi başarısız oldu";
                case 20: return @"Bağlama sınırına ulaşıldı";
                case 50: return @"Sunucu hatası 4";
                case 61: return @"Kullanıcı doğrulaması başarısız oldu";
                case 1101: return @"İstek zaman aşımına uğradı";
                case 1102: return @"Sunucuya erişilemiyor";
                case 1103: return @"Bilinmeyen hata";
                case 1104: return @"Dosya yükleme başarısız oldu";
                case 80002: return @"Ses yok";
                default: return nil;
            }
            break;
        }
        case 0x26: {// Bengali
            switch (errorCode) {
                case 1: return @"সার্ভার ত্রুটি ১";
                case 2: return @"সার্ভার ত্রুটি ২";
                case 3: return @"সার্ভার ত্রুটি ৩";
                case 4: return @"শনাক্তকরণ খালি";
                case 5: return @"অনুরোধ প্যারামিটার ত্রুটি";
                case 6: return @"TTS সমর্থিত নয়";
                case 7: return @"STT সমর্থিত নয়";
                case 8: return @"পর্যাপ্ত সময়";
                case 9: return @"আজকের বিনামূল্যের সময় শেষ হয়ে গেছে";
                case 10: return @"মুক্ত সময় শেষ হয়ে গেছে";
                case 11: return @"প্রদত্ত ফাংশন";
                case 12: return @"সংবেদনশীল শব্দ জড়িত, অনুগ্রহ করে আবার চেষ্টা করুন";
                case 13: return @"দয়া করে ঘড়ি দ্বারা সমর্থিত একটি ভাষা ব্যবহার করুন";
                case 14: return @"জেনারেট করা হচ্ছে";
                case 18: return @"মিটিং তৈরি করা যায়নি";
                case 19: return @"স্বাস্থ্য বিশ্লেষণ ব্যর্থ হয়েছে";
                case 20: return @"বাইন্ডিং সীমা পৌঁছেছে";
                case 50: return @"সার্ভার ত্রুটি ৪";
                case 61: return @"ব্যবহারকারী যাচাইকরণ ব্যর্থ হয়েছে";
                case 1101: return @"অনুরোধের সময়সীমা শেষ";
                case 1102: return @"সার্ভার অ্যাক্সেস করতে অক্ষম";
                case 1103: return @"অজানা ত্রুটি";
                case 1104: return @"ফাইল আপলোড ব্যর্থ হয়েছে";
                case 80002: return @"কোন শব্দ নেই";
                default: return nil;
            }
            break;
        }
        case 0x27: {// Ukrainian
            switch (errorCode) {
                case 1: return @"Помилка сервера 1";
                case 2: return @"Помилка сервера 2";
                case 3: return @"Помилка сервера 3";
                case 4: return @"Ідентифікація порожня";
                case 5: return @"Помилка параметра запиту";
                case 6: return @"TTS не підтримується";
                case 7: return @"STT не підтримується";
                case 8: return @"Недостатньо часу";
                case 9: return @"Сьогоднішній вільний час використано";
                case 10: return @"Безкоштовний час використано";
                case 11: return @"Платна функція";
                case 12: return @"Міститься конфіденційна інформація, спробуйте ще раз";
                case 13: return @"Будь ласка, використовуйте мову, яку підтримує годинник";
                case 14: return @"Генерація";
                case 18: return @"Не вдалося створити зустріч";
                case 19: return @"Аналіз стану не вдався";
                case 20: return @"Досягнуто ліміту зв'язування";
                case 50: return @"Помилка сервера 4";
                case 61: return @"Верифікація користувача не вдалася";
                case 1101: return @"Час очікування запиту минув";
                case 1102: return @"Не вдається отримати доступ до сервера";
                case 1103: return @"Невідома помилка";
                case 1104: return @"Завантаження файлу не вдалося";
                case 80002: return @"Не чути звуку";
                default: return nil;
            }
            break;
        }
        case 0x29: {// Persian (Farsi)
            switch (errorCode) {
                case 1: return @"خطای سرور ۱";
                case 2: return @"خطای سرور ۲";
                case 3: return @"خطای سرور ۳";
                case 4: return @"شناسایی خالی است";
                case 5: return @"خطای پارامتر درخواست";
                case 6: return @"TTS پشتیبانی نمی‌شود";
                case 7: return @"STT پشتیبانی نمی‌شود";
                case 8: return @"زمان‌های ناکافی";
                case 9: return @"زمان‌های آزاد امروز تمام شده‌اند";
                case 10: return @"زمان‌های آزاد تمام شده‌اند";
                case 11: return @"عملکرد پولی";
                case 12: return @"کلمات حساسی وجود دارد، لطفاً دوباره امتحان کنید";
                case 13: return @"لطفاً از زبانی استفاده کنید که توسط ساعت پشتیبانی می‌شود";
                case 14: return @"در حال تولید";
                case 18: return @"ایجاد جلسه ناموفق بود";
                case 19: return @"تحلیل سلامت ناموفق بود";
                case 20: return @"به محدودیت اتصال رسیده است";
                case 50: return @"خطای سرور ۴";
                case 61: return @"تأیید کاربر ناموفق بود";
                case 1101: return @"زمان درخواست منقضی شده است";
                case 1102: return @"دسترسی به سرور امکان‌پذیر نیست";
                case 1103: return @"خطای ناشناخته";
                case 1104: return @"آپلود فایل ناموفق بود";
                case 80002: return @"هیچ صدایی وجود ندارد";
                default: return nil;
            }
            break;
        }
        case 0x2A: {// Khmer (Cambodian)
            switch (errorCode) {
                case 1: return @"កំហុសម៉ាស៊ីនមេ 1";
                case 2: return @"កំហុសម៉ាស៊ីនមេ 2";
                case 3: return @"កំហុសម៉ាស៊ីនមេ 3";
                case 4: return @"ការកំណត់អត្តសញ្ញាណគឺទទេ";
                case 5: return @"កំហុសប៉ារ៉ាម៉ែត្រស្នើសុំ";
                case 6: return @"TTS មិនត្រូវបានគាំទ្រទេ។";
                case 7: return @"STT មិនត្រូវបានគាំទ្រទេ។";
                case 8: return @"ពេលវេលាមិនគ្រប់គ្រាន់";
                case 9: return @"ពេលទំនេរថ្ងៃនេះត្រូវបានប្រើប្រាស់អស់ហើយ។";
                case 10: return @"ពេលទំនេរត្រូវបានប្រើប្រាស់អស់ហើយ។";
                case 11: return @"មុខងារបង់ប្រាក់";
                case 12: return @"ពាក្យរសើបដែលពាក់ព័ន្ធ សូមព្យាយាមម្តងទៀត";
                case 13: return @"សូមប្រើភាសាដែលគាំទ្រដោយនាឡិកា";
                case 14: return @"ការបង្កើត";
                case 18: return @"ការបង្កើតការប្រជុំបានបរាជ័យ";
                case 19: return @"ការវិភាគសុខភាពបានបរាជ័យ";
                case 20: return @"ឈានដល់ដែនកំណត់នៃការចង";
                case 50: return @"កំហុសម៉ាស៊ីនមេ 4";
                case 61: return @"ការផ្ទៀងផ្ទាត់អ្នកប្រើប្រាស់បានបរាជ័យ";
                case 1101: return @"ស្នើសុំអស់ពេល";
                case 1102: return @"មិនអាចចូលប្រើម៉ាស៊ីនមេបានទេ។";
                case 1103: return @"កំហុសមិនស្គាល់";
                case 1104: return @"ការបង្ហោះឯកសារបានបរាជ័យ";
                case 80002: return @"មិនមានសម្លេងទេ";
                default: return nil;
            }
            break;
        }
        case 0x2B: {// Malay
            switch (errorCode) {
                case 1: return @"Ralat pelayan 1";
                case 2: return @"Ralat pelayan 2";
                case 3: return @"Ralat pelayan 3";
                case 4: return @"Pengenalan kosong";
                case 5: return @"Permintaan ralat parameter";
                case 6: return @"TTS tidak disokong";
                case 7: return @"STT tidak disokong";
                case 8: return @"Masa yang tidak mencukupi";
                case 9: return @"Masa lapang hari ini sudah habis";
                case 10: return @"Masa lapang telah digunakan";
                case 11: return @"Fungsi berbayar";
                case 12: return @"Perkataan sensitif yang terlibat, sila cuba lagi";
                case 13: return @"Sila gunakan bahasa yang disokong oleh jam tangan";
                case 14: return @"Menjana";
                case 18: return @"Penciptaan mesyuarat gagal";
                case 19: return @"Analisis kesihatan gagal";
                case 20: return @"Had mengikat telah dicapai";
                case 50: return @"Ralat pelayan 4";
                case 61: return @"Pengesahan pengguna gagal";
                case 1101: return @"Minta tamat masa";
                case 1102: return @"Tidak dapat mengakses pelayan";
                case 1103: return @"Ralat tidak diketahui";
                case 1104: return @"Muat naik fail gagal";
                case 80002: return @"Tidak ada suara";
                default: return nil;
            }
            break;
        }
        default: {// 默认英文
            switch (errorCode) {
                case 1: return @"Server error 1";
                case 2: return @"Server error 2";
                case 3: return @"Server error 3";
                case 4: return @"Identification is empty";
                case 5: return @"Request parameter error";
                case 6: return @"TTS is not supported";
                case 7: return @"STT is not supported";
                case 8: return @"Insufficient times";
                case 9: return @"Today's free times have been used up";
                case 10: return @"Free times have been used up";
                case 11: return @"Paid function";
                case 12: return @"Sensitive words involved, please try again";
                case 13: return @"Please use a language supported by the watch";
                case 14: return @"Generating";
                case 18: return @"Meeting creation failed";
                case 19: return @"Health analysis failed";
                case 20: return @"Binding limit reached";
                case 50: return @"Server error 4";
                case 61: return @"User verification failed";
                case 1101: return @"Request timeout";
                case 1102: return @"Unable to access server";
                case 1103: return @"Unknown error";
                case 1104: return @"File upload failed";
                case 80002: return @"There is no sound";
                default: return nil;
            }
        }
    }
    return nil;
}

@end

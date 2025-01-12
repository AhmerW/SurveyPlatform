# offset, limit should always be last 2 placeholder args (if the query requires them)
# (as "LIMIT ?, ?;" aka "LIMIT OFFSET, LIMIT;"")
class SurveyQueries:
    CreateSurvey = """
        INSERT INTO Surveys(title, pages, points, duration, draft) VALUES(?, ?, ?, ?, ?)
    """
    GetAllVisibleSurveys = """
        SELECT * FROM Surveys
        JOIN Questions ON Questions.survey_id = Surveys.survey_id
        WHERE draft = False;
    """
    GetAllSurveyDrafts = """
        SELECT * FROM Surveys
        JOIN Questions ON Questions.survey_id = Surveys.survey_id
        WHERE draft = True;
    """
    GetAllUSurveys = """
        SELECT * FROM Surveys
        JOIN Questions ON Questions.survey_id = Surveys.survey_id;
    """
    DeleteWhereId = """
        DELETE FROM Surveys WHERE Surveys.survey_id = ?
    """
    UpdateSurvey = """
        UPDATE Surveys SET title=?, pages=?, points=?, duration=?, draft=? WHERE Surveys.survey_id = ?;
    """
    GetWhereID = """
        SELECT * FROM Surveys WHERE Surveys.survey_id = ?;
    """


class QuestionQueries:
    CreateQuestion = """
        INSERT INTO Questions(survey_id, question_text, widget, widget_values, position) VALUES(?, ?, ?, ?, ?)
    """

    GetAllQuestionsWithSurveyId = """
        SELECT * FROM Questions WHERE Questions.survey_id = ?
    """


class UserQueries:
    FromUsername = """
        SELECT * FROM Users WHERE username = ?
    """
    FromUsernameOrEmail = """
        SELECT * FROM Users WHERE username = ? or email = ?;
    """
    FromUid = """
        SELECT * FROM Users WHERE uid = ?
    """
    UpdatePoints = """
        UPDATE Users SET points = points + ? WHERE uid = ?
    """

    AnyExists = """
        SELECT * FROM Users WHERE username = ? or email = ?
    """

    CreateUser = """
        INSERT INTO Users(username, email, password) VALUES(?, ?, ?)
    """
    UpdateVerificationState = """
        UPDATE Users set verified = ? WHERE uid = ?
    """
    UpdatePassword = """
        UPDATE Users set password = ? WHERE uid = ?;
    """


class AnswerQueries:
    SubmitAnswer = """
        INSERT INTO SurveyAnswers(uid, survey_id, timestamp) VALUES(?, ?, ?);
    """
    SubmitQuestionAnswer = """
        INSERT INTO QuestionAnswers(question_id, answer_id, value) VALUES(?, ?, ?)
    """
    GetUserAnswer = """
        SELECT * FROM SurveyAnswers where survey_id = ? and uid = ?;
    """
    GetAnswers = """
        SELECT * FROM SurveyAnswers
        JOIN QuestionAnswers 
        on QuestionAnswers.answer_id = SurveyAnswers.answer_id;
    """

    GetSurveyAnswers = """
        SELECT * FROM SurveyAnswers
        JOIN QuestionAnswers 
        on QuestionAnswers.answer_id = SurveyAnswers.answer_id
        WHERE SurveyAnswers.survey_id = ?;
    """


class GiftQueries:
    CreateGift = """
        INSERT INTO Gifts(uid, price, title, description) VALUES(?, ?, ?, ?);
    """
    GetGift = """
        SELECT * FROM Gifts WHERE Gifts.gift_id = ?;
    """
    GetGifts = """
        SELECT g.*, count(*) AS item_count 
        FROM Gifts AS g left join GiftItems AS i
        ON g.gift_id = i.gift_id GROUP BY g.gift_id
    """
    DeleteGift = """
        DELETE FROM Gifts WHERE Gifts.gift_id = ?;
    """

    GetGiftItems = """
        SELECT * FROM GiftItems WHERE GiftItems.gift_id = ?;
    """
    GetGiftItem = """
        SELECT * FROM GiftItems WHERE GiftItems.item_id = ?;
    """
    GetUnclaimedGiftItems = """
        SELECT * FROM GiftItems WHERE GiftItems.gift_id = ? and GiftItems.claimed = false;
    """
    GetClaimedGiftItems = """
        SELECT * FROM GiftItems WHERE GiftItems.gift_id = ? and GiftItems.claimed = true;
    """
    GetUserClaimedGiftItems = """
        SELECT * FROM GiftItems WHERE claimed = true and claimed_by = ?;
    """

    AddGiftItem = """
        INSERT INTO GiftItems(gift_id, value) VALUES (?, ?);
    """

    DeleteGiftItem = """
        DELETE FROM GiftItems where GiftItems.item_id = ?;
    """
    DeleteGiftItems = """
        DELETE FROM GiftItems WHERE GiftItems.gift_id = ? AND GiftItems.claimed = false;
    """
    ClaimGiftItem = """
        UPDATE GiftItems SET claimed = true, claimed_by = ? WHERE GiftItems.item_id = ?;
    """
    GetGiftItemsCount = """
        SELECT COUNT(*) from GiftItems WHERE GiftItems.gift_id = ?;
    """

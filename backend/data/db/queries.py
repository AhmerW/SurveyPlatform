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
    FromUid = """
        SELECT * FROM Users WHERE uid = ?
    """

    AnyExists = """
        SELECT * FROM Users WHERE username = ? or email = ?
    """

    CreateUser = """
        INSERT INTO Users(username, email, password) VALUES(?, ?, ?)
    """
    UpdateVerificationState = """
        UPDATE Users set verified = ? where uid = ?
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


class GiftQueries:
    CreateGift = """
        INSERT INTO Gifts(price, title, description) VALUES(?, ?, ?);
    """
    GetGiftById = """
        SELECT * FROM Gifts WHERE Gifts.gift_id = ?;
    """

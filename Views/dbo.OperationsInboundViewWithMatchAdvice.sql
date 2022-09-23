SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[OperationsInboundViewWithMatchAdvice]      
AS      
SELECT	OperationsInboundView.*,
		TransactionInfo.MatchCompanyID,
		TransactionInfo.MatchTransactionID,
		dbo.MatchRecommendationForPower_fn(TransactionInfo.MatchCompanyID, TransactionInfo.MatchTransactionID, OperationsInboundView.Tractor) MatchRecommendation,
		Optimals.ma_tour_number MatchTourNumber,
		PowerState.EstimatedPta MatchEstPTA,
		CASE WHEN ISNULL(PowerState.EstimatedPtaPostal, '') = '' THEN '' ELSE CASE WHEN ISNULL(PowerState.EstimatedPtaCity, '') = '' THEN 'UNKNOWN' ELSE PowerState.EstimatedPtaCity END + ', ' + CASE WHEN ISNULL(PowerState.EstimatedPtaState, '') = '' THEN 'UNK' ELSE PowerState.EstimatedPtaState END END MatchEstPTACity,
		PowerState.EstimatedPtaPostal MatchEstPTAPostal, 
		PowerState.DriveHoursLeft MatchEstDriveHrsAtPTA,
		PowerState.DutyHoursLeft MatchEstDutyHrsAtPTA,
		PowerState.DutyHoursLeftWeek MatchEstWeekHrsAtPTA,
		STR(ROUND(PowerState.DriveHoursLeft, 2), 5, 2) + '/' + STR(ROUND(PowerState.DutyHoursLeft, 2), 5, 2) + '/' + STR(ROUND(PowerState.DutyHoursLeftWeek, 2), 5, 2) MatchEstHrsAtPTA
  FROM	OperationsInboundView
			INNER JOIN (SELECT	TOP 1
								CASE
									WHEN LEFT(ISNULL(gi_string1, 'N'), 1) = 'Y' THEN (SELECT TOP 1 company_id FROM	LastMATransactionID WHERE company_id = (SELECT ISNULL(ttsusers.usr_type1, 'XXXXXXXX') FROM ttsusers WHERE usr_userid = dbo.gettmwuser_fn()) ORDER BY inserted_date DESC)
									ELSE (SELECT TOP 1 company_id FROM	LastMATransactionID ORDER BY inserted_date DESC)
								END MatchCompanyID,
								CASE
									WHEN LEFT(ISNULL(gi_string1, 'N'), 1) = 'Y' THEN (SELECT TOP 1 transaction_id FROM	LastMATransactionID WHERE company_id = (SELECT ISNULL(ttsusers.usr_type1, 'XXXXXXXX') FROM ttsusers WHERE usr_userid = dbo.gettmwuser_fn()) ORDER BY inserted_date DESC)
									ELSE (SELECT TOP 1 transaction_id FROM	LastMATransactionID ORDER BY inserted_date DESC)
								END MatchTransactionID
						  FROM	generalinfo
						 WHERE	gi_name = 'MatchAdviceMultiCompany') TransactionInfo ON 1=1
			LEFT OUTER JOIN ma_optimals Optimals ON Optimals.company_id = TransactionInfo.MatchCompanyID AND Optimals.ma_transaction_id = TransactionInfo.MatchTransactionID AND Optimals.trc_number = OperationsInboundView.Tractor AND Optimals.ma_tour_sequence = 1
			LEFT OUTER JOIN PowerState ON PowerState.CompanyId = TransactionInfo.MatchCompanyID AND PowerState.PowerId = OperationsInboundView.Tractor
GO
GRANT SELECT ON  [dbo].[OperationsInboundViewWithMatchAdvice] TO [public]
GO

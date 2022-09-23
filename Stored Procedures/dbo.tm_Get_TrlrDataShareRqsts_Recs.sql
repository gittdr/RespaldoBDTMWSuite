SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_TrlrDataShareRqsts_Recs] 
AS
	BEGIN
		SELECT 
				Trailerid,
				TractorID,
				RespFormID,
				SCAC,
				DataSharing,
				Partner,
				DTSent,
				DTRcvd,
				RqstSent,
				DTRqstSent,
				AckSent,
				DTAckSent
		  FROM 
				dbo.tblDataShareMsgs   WITH (NOLOCK)
		 WHERE 
				RqstSent = 'N'
		   AND	
				AckSent = 'N'
	END

GO
GRANT EXECUTE ON  [dbo].[tm_Get_TrlrDataShareRqsts_Recs] TO [public]
GO

CREATE TABLE [dbo].[TMSQLMessageData]
(
[msd_ID] [int] NOT NULL IDENTITY(1, 1),
[msg_ID] [int] NOT NULL,
[msd_Seq] [int] NOT NULL,
[msd_FieldName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msd_FieldValue] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Lori Brickley
-- Create date: 03/24/2017
-- Description:	Determines the product responsible for sending the mobile comm message (TotalMail or FleetConneX)
-- and moves the message to the appropriate table (if FleetConnex)
-- =============================================
CREATE TRIGGER [dbo].[ioitTMSQLMessageData] 
   ON [dbo].[TMSQLMessageData]
   INSTEAD OF INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 from INSERTED)
	BEGIN

    IF EXISTS (SELECT 1 FROM INSERTED a
		JOIN mobileCommMessageQueue b on a.msg_id = b.msg_id)
	BEGIN
    
	INSERT INTO MobileCommMessageQueueFields 
      (msg_id
        , msd_Seq
        , msd_fieldname
        , msd_fieldvalue)
		SELECT a.msg_id
      , msd_Seq
      , msd_fieldname
      , msd_fieldvalue
		FROM  INSERTED a
      JOIN MobileCommMessageQueue b on a.msg_id = b.msg_id;
	  
	END;

    IF EXISTS (SELECT 1 FROM INSERTED a
        WHERE NOT EXISTS (SELECT 1 FROM MobileCommMessageQueue b WHERE a.msg_id = b.msg_id))
    BEGIN 
  
    INSERT INTO TMSQLMessageData 
      (msg_id
        , msd_Seq
        , msd_fieldname
        , msd_fieldvalue)
		SELECT a.msg_id
      , msd_Seq
      , msd_fieldname
      , msd_fieldvalue
		FROM  INSERTED a
		WHERE NOT EXISTS (SELECT 1 FROM MobileCommMessageQueue b WHERE a.msg_id = b.msg_id)
      
	END;
END;
END;
GO
GRANT DELETE ON  [dbo].[TMSQLMessageData] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSQLMessageData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMSQLMessageData] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSQLMessageData] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSQLMessageData] TO [public]
GO

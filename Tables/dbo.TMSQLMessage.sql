CREATE TABLE [dbo].[TMSQLMessage]
(
[msg_ID] [int] NOT NULL IDENTITY(1, 1),
[msg_date] [datetime] NOT NULL,
[msg_FormID] [int] NOT NULL,
[msg_To] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msg_ToType] [int] NOT NULL,
[msg_FilterData] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msg_FilterDataDupWaitSeconds] [int] NULL,
[msg_From] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msg_FromType] [int] NOT NULL,
[msg_Subject] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TranInstance] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itTMSQLMessage2] 
   ON  [dbo].[TMSQLMessage]
   FOR INSERT
AS 
BEGIN
	-- =============================================
	-- Author:		Rob Scott
	-- Create date: 03/24/2017
	-- Description:	Determines the product responsible for sending the mobile comm message (TotalMail or FleetConneX)
	-- and moves the message to the appropriate table (if FleetConnex)
	-- =============================================
	-- Change History:
	-- 04/03/2017 - AMB: Removed the asset type specification when the asset id is prefixed with DRV/TRC.
	-- 04/25/2017 - AMB: Accounted for a bug in Fuel where the messageToType is incorrectly being set to a tractor
	--					 for a driver asset message.
	-- 08/21/2017 - AMB: Added support to copy the values of a new column, MessageGroup, which got added to MobileCommFleet and
    --	                 MobileCommMessageQueue
	-- =============================================

	-- NOTE: The below are the only accepted addressing types in FleetConneX
	-- This note was created on 04/25/2017.
	-- 4 = Truck						The object is a TotalMail Truck or Truck Group Name.
	-- 5 = Driver						The object is a TotalMail Driver Name.
	-- 9 = Dispatch System Truck ID		The object is a Truck ID for the Dispatch System that TotalMail is connected to.
	-- 10 = Dispatch System Driver ID	The object is a Driver ID for the Dispatch System that TotalMail is connected to.
	
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 from INSERTED)
	BEGIN

		-- We need to retrieve the message group in order to 
		-- correctly route messages
		DECLARE @messageGroup INT;
		
		SET @messageGroup = COALESCE((
		  SELECT TOP 1 MessageGroup
		  FROM MobileCommFleets a
			INNER JOIN INSERTED b ON b.msg_to = a.AssetId
		  WHERE a.AssetType = 'DRIVER' AND
				b.msg_toType IN (5,10)
		  UNION ALL
		  /* in case from fuel dispatch */
		  SELECT TOP 1 MessageGroup
		  FROM MobileCommFleets a
			INNER JOIN INSERTED b ON b.msg_to = 'DRV:' + a.AssetId
		  WHERE a.AssetType = 'DRIVER'
		  UNION ALL
		  SELECT TOP 1 MessageGroup
		  FROM MobileCommFleets a
				INNER JOIN INSERTED b ON b.msg_to = a.AssetId
		  WHERE a.AssetType = 'TRACTOR' AND 
				b.msg_toType IN (4,9)
		  UNION ALL 
		  /* in case from fuel dispatch */
		  SELECT TOP 1 MessageGroup
		  FROM MobileCommFleets a
				INNER JOIN INSERTED b ON b.msg_to = 'TRC:' + a.AssetId
		  WHERE a.AssetType = 'TRACTOR'
		)
		, -9999);

		-- if we have -9999, then we do not have a record in the table,
		-- that matches a FleetConneX outbound message, so exit processing
		IF (@messageGroup <> -9999)    
			BEGIN
				-- despite the default being 1 on the MessageGroup column, 
				-- if we have a value less than one (1), default to one
				IF (@messageGroup <= 0)
				BEGIN
					SELECT @messageGroup = 1
				END

				INSERT INTO dbo.MobileCommMessageQueue
						(msg_ID
						, msg_date
						, msg_FormID
						, msg_To
						, msg_ToType
						, msg_FilterData
						, msg_FilterDataDupWaitSeconds
						, msg_From, msg_FromType
						, msg_Subject
						, MessageGroup)
						SELECT msg_id
							, msg_date
							, msg_formID
							, CASE WHEN LEFT(msg_To,4) IN ('DRV:','TRC:') THEN RIGHT(msg_To,LEN(msg_To)-4) ELSE msg_to END
							, CASE WHEN LEFT(msg_To,4) = 'DRV:' THEN '10' 
								   WHEN LEFT(msg_To,4) = 'TRC:' THEN '9'
								   ELSE msg_ToType
							  END
							, msg_filterdata
							, msg_filterdatadupwaitseconds
							, msg_from
							, msg_fromType
							, msg_subject
							, @messageGroup
						FROM INSERTED;

				DELETE a                          -- since these are going to live somewhere else, don't need them.
				FROM TMSQLMessage a
					INNER JOIN MobileCommMessageQueue b ON a.msg_id = b.msg_id
					INNER JOIN INSERTED c ON a.msg_id = c.msg_id;
			END;
	END;
                      
END;

GO
GRANT DELETE ON  [dbo].[TMSQLMessage] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSQLMessage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMSQLMessage] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSQLMessage] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSQLMessage] TO [public]
GO

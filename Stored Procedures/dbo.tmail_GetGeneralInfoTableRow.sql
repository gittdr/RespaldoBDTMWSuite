SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetGeneralInfoTableRow] 
		@gi_Name varchar(30)

AS

DECLARE @gi_DateIn AS DATETIME
DECLARE @gi_String1 AS VARCHAR(60)
DECLARE @gi_String2 AS VARCHAR(60)
DECLARE @gi_String3 AS VARCHAR(60)
DECLARE @gi_String4 AS VARCHAR(60)
DECLARE @gi_Integer1 AS INTEGER
DECLARE @gi_Integer2 AS INTEGER
DECLARE @gi_Integer3 AS INTEGER
DECLARE @gi_Integer4 AS INTEGER
DECLARE @gi_Date1 AS DATETIME
DECLARE @gi_Date2 AS DATETIME
DECLARE @gi_AppID AS VARCHAR(4)
DECLARE @gi_Description AS VARCHAR(255)

BEGIN
	-------------------------------------------------------------------------------
	IF EXISTS(SELECT * 
				FROM dbo.generalinfo WITH (NOLOCK)
			   WHERE gi_name = @gi_Name)

		SELECT 
			@gi_Name = gi_name,
			@gi_DateIn = gi_datein,     -- Not nullable.
			@gi_String1 = ISNULL(gi_string1, ''), 
			@gi_String2 = ISNULL(gi_String2, ''),
			@gi_String3 = ISNULL(gi_string3, ''),
			@gi_String4 = ISNULL(gi_string4, ''),
			@gi_Integer1 = ISNULL(gi_integer1, 0),
			@gi_Integer2  = ISNULL(gi_integer2, 0),
			@gi_Integer3 = ISNULL(gi_integer3, 0),
			@gi_Integer4 = ISNULL(gi_integer4,0),
			@gi_Date1 = ISNULL(gi_Date1,0),
			@gi_Date2 = ISNULL(gi_Date2,0),
			@gi_AppID = ISNULL(gi_AppID, ''),
			@gi_Description = ISNULL(gi_Description, '')
		FROM 
			dbo.generalinfo WITH (NOLOCK)
		WHERE 
			gi_name = @gi_Name 
	ELSE
		SELECT 
			@gi_Name = 'No record',
			@gi_DateIn = '2012-07-07 12:00:00',
			@gi_String1 = 'No record found in General Info table.', 
			@gi_String2 = '',
			@gi_String3 = '',
			@gi_String4 = '',
			@gi_Integer1 = 0,
			@gi_Integer2  = 0,
			@gi_Integer3 = 0,
			@gi_Integer4 = 0,
			@gi_Date1 = 0,
			@gi_Date2 = 0,
			@gi_AppID = '',
			@gi_Description = ''

	-------------------------------------------------------------------------------		
	SELECT 
		@gi_Name AS 'giName', 
		@gi_DateIn AS 'giDateIn',
		@gi_String1 AS 'giString1',
		@gi_String2 AS 'giString2',
		@gi_String3 AS 'giString3',
		@gi_String4 AS 'giString4',
		@gi_Integer1 AS 'giInteger1',
		@gi_Integer2  AS 'giInteger2',
		@gi_Integer3 AS 'giInteger3',
		@gi_Integer4 AS 'giInteger4',
		@gi_Date1 AS 'giDate1',
		@gi_Date2 AS 'giDate2',
		@gi_AppID AS 'giAppID',
		@gi_Description AS 'giDescription'

	-------------------------------------------------------------------------------
END

GO
GRANT EXECUTE ON  [dbo].[tmail_GetGeneralInfoTableRow] TO [public]
GO

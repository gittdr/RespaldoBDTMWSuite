SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[MetricSearchUsers] (@FilterType varchar(50), @FilterValue varchar(20), @Status varchar(10))
AS
	SET NOCOUNT ON

	DECLARE @nStatus int

	IF (@Status <> 'ENABLED' AND @Status <> 'DISABLED')
		RETURN

	IF (@FilterType <> 'NT' AND @FilterType <> 'GENERIC' AND @FilterType <> 'SQL' )
		RETURN

	IF @Status = 'ENABLED' SET @nStatus = 0 ELSE SET @nStatus = 1

	IF @FilterType = 'NT'
		SELECT sn, ISNULL(NTUser, '') AS NTUser, ISNULL(SQLUser, '') AS SQLUser, ISNULL(GenericUser, '') AS GenericUser, CASE WHEN ISNULL(Disable, 0) = 0 THEN '' ELSE 'DISABLED' END AS Disable 
		FROM MetricUser WHERE ISNULL(NTUser, '') LIKE '%' + @FilterValue + '%' 
						AND ISNULL(Disable, 0) = @nStatus
		ORDER BY NTUser 

	ELSE IF @FilterType = 'SQL' 
		SELECT sn, ISNULL(NTUser, '') AS NTUser, ISNULL(SQLUser, '') AS SQLUser, ISNULL(GenericUser, '') AS GenericUser, CASE WHEN ISNULL(Disable, 0) = 0 THEN '' ELSE 'DISABLED' END AS Disable 
		FROM MetricUser WHERE ISNULL(SQLUser, '') LIKE '%' + @FilterValue + '%' 
						AND ISNULL(Disable, 0) = @nStatus
		ORDER BY NTUser 

	ELSE IF @FilterType = 'GENERIC' 
		SELECT sn, ISNULL(NTUser, '') AS NTUser, ISNULL(SQLUser, '') AS SQLUser, ISNULL(GenericUser, '') AS GenericUser, CASE WHEN ISNULL(Disable, 0) = 0 THEN '' ELSE 'DISABLED' END AS Disable 
		FROM MetricUser WHERE ISNULL(GenericUser, '') LIKE '%' + @FilterValue + '%'
						AND ISNULL(Disable, 0) = @nStatus
GO
GRANT EXECUTE ON  [dbo].[MetricSearchUsers] TO [public]
GO

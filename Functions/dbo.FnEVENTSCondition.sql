SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[FnEVENTSCondition] 
(
@Collection VARCHAR(MAX),
@ORD_HDRNUMBER int,
@WORKFLOWTEMPLATEID int,
@Type varchar(50)
)
RETURNS VARCHAR(MAX)
AS

BEGIN
DECLARE @Column varchar(30), @Column_End int,@ResultVar varchar(max)


 SET @ResultVar = 'SELECT COUNT(0) FROM EVENT E JOIN STOPS S ON S.STP_NUMBER = E.STP_NUMBER RIGHT JOIN WCEVENTTRACKING_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' ET ON ET.STP_NUMBER = E.STP_NUMBER 
			WHERE ET.STP_TYPE IN ('+@Type+') AND ET.STP_NUMBER = E.STP_NUMBER AND e.evt_number = et.evt_number and E.ORD_HDRNUMBER =' +CONVERT(VARCHAR(50),@ORD_HDRNUMBER)  
			WHILE LEN(@Collection) > 0
				BEGIN --WHILE
				SET @Column_End = CHARINDEX(',', @Collection)
				IF @Column_End = 0
				SET @Column_End = LEN(@Collection) + 1
				SET @Column = LTRIM(RTRIM(LEFT(@Collection, @Column_End - 1)))
				SET @ResultVar = @ResultVar  + ' AND ISNULL(E.[' + @Column + '],0)  =  ISNULL(ET.[' + @Column + ']'+',0)'
				SET @Collection = SUBSTRING(@Collection, @Column_End + 1, 2000000000)
				END --WHILE
			--INSERT @TempTable
	
	RETURN @ResultVar

END

GO
GRANT EXECUTE ON  [dbo].[FnEVENTSCondition] TO [public]
GO

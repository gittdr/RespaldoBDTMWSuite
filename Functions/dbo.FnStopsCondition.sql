SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[FnStopsCondition] 
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

SET @ResultVar = 'SELECT COUNT(0) FROM STOPS S RIGHT JOIN WCSTOPTRACKING_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' ST ON ST.ORD_HDRNUMBER = S.ORD_HDRNUMBER 
			WHERE  S.STP_NUMBER = ST.STP_NUMBER AND S.STP_TYPE IN ('+@Type+') AND S.ORD_HDRNUMBER =' +CONVERT(VARCHAR(50),@ORD_HDRNUMBER)   
			WHILE LEN(@Collection) > 0
				BEGIN --WHILE
				SET @Column_End = CHARINDEX(',', @Collection)
				IF @Column_End = 0
				SET @Column_End = LEN(@Collection) + 1
				SET @Column = LTRIM(RTRIM(LEFT(@Collection, @Column_End - 1)))
				SET @ResultVar = @ResultVar  + ' AND ISNULL(S.[' + @Column + '],0)  =  ISNULL(ST.[' + @Column + ']'+',0)'
				SET @Collection = SUBSTRING(@Collection, @Column_End + 1, 2000000000)
				END --WHILE
			--INSERT @TempTable
	
	RETURN @ResultVar

END

GO
GRANT EXECUTE ON  [dbo].[FnStopsCondition] TO [public]
GO

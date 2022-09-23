SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[FnFreightsCondition] 
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
--IF (SELECT COUNT(0) FROM  WCFREIGHTTRACKING FT WHERE FT.STP_TYPE IN ('+@Type+''') AND FT.ORD_HDRNUMBER = @ORD_HDRNUMBER) <> 0
--BEGIN
SET @ResultVar = 'SELECT COUNT(0) FROM FREIGHTDETAIL F JOIN STOPS S ON S.STP_NUMBER = F.STP_NUMBER RIGHT JOIN WCFREIGHTTRACKING_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' FT ON FT.STP_NUMBER = F.STP_NUMBER 
			WHERE FT.STP_TYPE IN ('+@Type+') AND FT.STP_NUMBER =F.STP_NUMBER AND FT.STP_NUMBER = S.STP_NUMBER AND S.ORD_HDRNUMBER =' +CONVERT(VARCHAR(50),@ORD_HDRNUMBER)   
			WHILE LEN(@Collection) > 0
				BEGIN --WHILE
				SET @Column_End = CHARINDEX(',', @Collection)
				IF @Column_End = 0
				SET @Column_End = LEN(@Collection) + 1
				SET @Column = LTRIM(RTRIM(LEFT(@Collection, @Column_End - 1)))
				SET @ResultVar = @ResultVar  + ' AND ISNULL(F.[' + @Column + '],0)  =  ISNULL(FT.[' + @Column + ']'+',0)'
				SET @Collection = SUBSTRING(@Collection, @Column_End + 1, 2000000000)
				END --WHILE
			--INSERT @TempTable
		RETURN @ResultVar
--END
--		RETURN 'NO RECORD FOUND'
END


GO
GRANT EXECUTE ON  [dbo].[FnFreightsCondition] TO [public]
GO

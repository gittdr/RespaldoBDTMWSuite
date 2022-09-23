SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [dbo].[SystemsLinkFreightsCondition] 
(
@Collection VARCHAR(MAX),
@ORD_HDRNUMBER int,
@WORKFLOWTEMPLATEID int,
@Type varchar(50),
@ReturnVal varchar(max) output


)

AS

BEGIN
DECLARE @Column varchar(30), @Column_End int, @ResultVar VARCHAR(MAX), @InsrtSqlcmd varchar(MAX) , @Sqlcmd2 varchar(max)
DECLARE @TEMP table (tableName	varchar (50)) DECLARE @TEMP1 table (tableName	varchar (50)) 

SET @ReturnVal = 'SELECT COUNT(0) FROM FREIGHTDETAIL F JOIN STOPS S ON S.STP_NUMBER = F.STP_NUMBER RIGHT JOIN slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+
				' FT ON FT.STP_NUMBER = F.STP_NUMBER WHERE FT.STP_TYPE IN ('+@Type+') AND FT.STP_NUMBER =F.STP_NUMBER AND FT.STP_NUMBER = S.STP_NUMBER AND S.ORD_HDRNUMBER =' +CONVERT(VARCHAR(50),@ORD_HDRNUMBER)      
				WHILE LEN(@Collection) > 0
				BEGIN --WHILE
				SET @Column_End = CHARINDEX(',', @Collection)
				IF @Column_End = 0
				SET @Column_End = LEN(@Collection) + 1
				SET @Column = LTRIM(RTRIM(LEFT(@Collection, @Column_End - 1)))
				SET @ReturnVal = @ReturnVal  + ' AND ISNULL(F.[' + @Column + '],0)  =  ISNULL(FT.[' + @Column + ']'+',0)'
				SET @Collection = SUBSTRING(@Collection, @Column_End + 1, 2000000000)
				SET @InsrtSqlcmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message,odt_columnname, odt_oldvalue, odt_newvalue, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
				CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, f.fgt_number,''freightdetail'', ''Freightdetailchanged'','''+ @Column + ''', FT.['+CONVERT(VARCHAR(50),@Column)+'], F.['+CONVERT(VARCHAR(50),@Column)+'],GETDATE(),GETDATE(),0 FROM STOPS S, freightdetail f, slwcfreighttracking_'+
				CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' FT WHERE FT.STP_NUMBER = F.STP_NUMBER AND FT.ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+' AND S.ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+
				' AND S.STP_NUMBER = FT.STP_NUMBER AND ISNULL(F.[' + @Column + '],0) !=  ISNULL(FT.[' + @Column + '],0)'
				EXEC(@InsrtSqlcmd)
				END --WHILE
				
			--INSERT @TempTable
	


END

GO
GRANT EXECUTE ON  [dbo].[SystemsLinkFreightsCondition] TO [public]
GO

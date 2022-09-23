SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [dbo].[SystemsLinkStopsCondition] 
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

SET @ReturnVal = 'SELECT COUNT(0) FROM STOPS S RIGHT JOIN SLWCSTOPTRACKING_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+
				' ST ON ST.ORD_HDRNUMBER = S.ORD_HDRNUMBER WHERE  S.STP_NUMBER = ST.STP_NUMBER AND S.STP_TYPE IN ('+@Type+') AND S.ORD_HDRNUMBER =' +CONVERT(VARCHAR(50),@ORD_HDRNUMBER)   
			WHILE LEN(@Collection) > 0
				BEGIN --WHILE
				SET @Column_End = CHARINDEX(',', @Collection)
				IF @Column_End = 0
				SET @Column_End = LEN(@Collection) + 1
				SET @Column = LTRIM(RTRIM(LEFT(@Collection, @Column_End - 1)))
				SET @ReturnVal = @ReturnVal  + ' AND ISNULL(S.[' + @Column + '],0)  =  ISNULL(ST.[' + @Column + ']'+',0)'
				SET @Collection = SUBSTRING(@Collection, @Column_End + 1, 2000000000)
				SET @InsrtSqlcmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message,odt_columnname, odt_oldvalue, odt_newvalue, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
				CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, s.stp_number,''stops'', ''Stopschanged'','''+ @Column + ''', ST.['+CONVERT(VARCHAR(50),@Column)+'], S.['+CONVERT(VARCHAR(50),@Column)+'],GETDATE(),GETDATE(),0 FROM STOPS S, SLWCSTOPTRACKING_'+
				CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' ST WHERE ST.ORD_HDRNUMBER = S. ORD_HDRNUMBER AND ST.ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+' AND S.ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+
				' AND S.STP_NUMBER = ST.STP_NUMBER AND ISNULL(S.[' + @Column + '],0) !=  ISNULL(ST.[' + @Column + '],0)'
				EXEC(@InsrtSqlcmd)
				END --WHILE
				
END

GO
GRANT EXECUTE ON  [dbo].[SystemsLinkStopsCondition] TO [public]
GO

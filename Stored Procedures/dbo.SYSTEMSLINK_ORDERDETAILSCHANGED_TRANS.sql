SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SYSTEMSLINK_ORDERDETAILSCHANGED_TRANS]
@Ord_hdrnumber INT, @WorkflowID INT, 
@OrderCollection VARCHAR(1000), @StopCollection VARCHAR(1000), @FreightCollection VARCHAR(1000), @EventCollection VARCHAR(1000), @REFTYPECollection VARCHAR(1000),
@PUPStopCollection VARCHAR(1000),@DRPStopCollection VARCHAR(1000), @ALLStopCollection VARCHAR(1000),@NONEStopCollection VARCHAR(1000),
@PUPFREIGHTCollection VARCHAR(1000),@DRPFREIGHTCollection VARCHAR(1000) , @ALLFREIGHTCollection VARCHAR(1000), @NONEFREIGHTCollection VARCHAR(1000),
@PUPEVENTCollection VARCHAR(1000),@DRPEVENTCollection VARCHAR(1000) , @ALLEVENTCollection VARCHAR(1000), @NONEEVENTCollection VARCHAR(1000), 
@Initialize varchar(10), @Result varchar(50) OUTPUT, @STOPRESULT varchar(50) OUTPUT, @FREIGHTRESULT varchar(50) OUTPUT, @EVENTRESULT varchar(50) OUTPUT, @REFRESULT varchar(50) OUTPUT,
@ErrorNumber INT OUTPUT, @ErrorLine INT OUTPUT, @ErrorMessage NVARCHAR(4000) OUTPUT, @ReturnVal NVARCHAR(4000) OUTPUT

AS

DECLARE @SqlCmd VARCHAR(MAX) DECLARE @Sqltbl VARCHAR(500) DECLARE @InsrtSqlcmd VARCHAR(MAX)
DECLARE @OrderCollectionCopy VARCHAR(MAX) = @OrderCollection DECLARE @StopCollectionCopy VARCHAR(MAX) = @StopCollection 
DECLARE @FreightCollectionCopy VARCHAR(MAX) = @FreightCollection DECLARE @EVENTCollectionCopy VARCHAR(MAX) = @EVENTCollection 
DECLARE @REFNUMCollectionCopy VARCHAR(MAX) = @REFTYPECollection
DECLARE @WORKFLOWTEMPLATEID INT


Declare @ID int, @Columns varchar(max), @Column varchar(30), @Column_End int, @Sql varchar(max)

DECLARE @TEMP table (tableName	varchar (50)) DECLARE @TEMP1 table (tableName	varchar (50)) 

BEGIN -- SP

	BEGIN TRY
		BEGIN TRANSACTION
			SELECT @WORKFLOWTEMPLATEID = WORKFLOW_TEMPLATE_ID FROM WORKFLOW WHERE WORKFLOW_ID = CONVERT(VARCHAR(50),@WORKFLOWID)
			SET @ErrorNumber = 0
			SET @ErrorLine =0
			SET @ErrorMessage = ' '		
			IF @Initialize IS NULL
				SET @Initialize = 'Y'
			IF @Initialize = 'Y'
			BEGIN
				DELETE FROM @TEMP
				IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'orderdatatracking'))
				BEGIN
					CREATE TABLE orderdatatracking
					(
						odt_id int IDENTITY(1,1) NOT NULL,
						ord_hdrnumber int null,
						mov_number int null,
						lgh_number int null,
						odt_tablekey int null,
						odt_tablename varchar(50) null,
						odt_message varchar(512) null,
						odt_columnname varchar(50) null,
						odt_oldvalue varchar(100) null,
						odt_newvalue varchar(100) null,
						odt_createddate datetime null,
						odt_createdby varchar(50) null,
						odt_updateddate datetime null,
						odt_updatedby varchar(50) null,
						odt_reviewed bit null,
						odt_revieweddate datetime null,
						odt_reviewedby varchar(50) null,
						CONSTRAINT [pk_orderdatatracking] PRIMARY KEY CLUSTERED 
						(
							[odt_id] 
						)
					)
					grant select, insert, update, delete on orderdatatracking to public
				END
				IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'ix_orderdatatracking_ord_hdrnumber' and id = OBJECT_ID('orderdatatracking'))
					create nonclustered index ix_orderdatatracking_ord_hdrnumber ON orderdatatracking(ord_hdrnumber)
				IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'ix_orderdatatracking_mov_number' and id = OBJECT_ID('orderdatatracking'))
					create nonclustered index ix_orderdatatracking_mov_number ON orderdatatracking(mov_number)
				IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'ix_orderdatatracking_lgh_number' and id = OBJECT_ID('orderdatatracking'))
					create nonclustered index ix_orderdatatracking_lgh_number ON orderdatatracking(lgh_number)
				IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'ix_orderdatatracking_odt_tablekey' and id = OBJECT_ID('orderdatatracking'))
					create nonclustered index ix_orderdatatracking_odt_tablekey ON orderdatatracking(odt_tablekey)
				IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'ix_orderdatatracking_odt_tablename' and id = OBJECT_ID('orderdatatracking'))
					create nonclustered index ix_orderdatatracking_odt_tablename ON orderdatatracking(odt_tablename)
				IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'ix_orderdatatracking_odt_createddate' and id = OBJECT_ID('orderdatatracking'))
					create nonclustered index ix_orderdatatracking_odt_createddate ON orderdatatracking(odt_createddate)
				IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'ix_orderdatatracking_odt_reviewed' and id = OBJECT_ID('orderdatatracking'))
					create nonclustered index ix_orderdatatracking_odt_reviewed ON orderdatatracking(odt_reviewed)
				IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'ix_orderdatatracking_odt_reviewedby' and id = OBJECT_ID('orderdatatracking'))
					create nonclustered index ix_orderdatatracking_odt_reviewedby ON orderdatatracking(odt_reviewedby)
				IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'ix_orderdatatracking_odt_revieweddate' and id = OBJECT_ID('orderdatatracking'))
					create nonclustered index ix_orderdatatracking_odt_revieweddate ON orderdatatracking(odt_revieweddate)
	
				-- WorkCycle OrderTracking	
				IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwcordertracking_' +CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
				BEGIN
					SET @SqlCmd = 'DROP TABLE slwcordertracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)
					EXEC(@SqlCmd)
				END	
				IF (@OrderCollectionCopy != ' ')
				BEGIN
					SET @SqlCmd = 'SELECT  IDENTITY(int, 1,1) AS ID, ORD_HDRNUMBER , ' +@OrderCollection+ ' INTO slwcordertracking_' +CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
					EXEC (@SqlCmd)
					SET @SqlCmd = 'CREATE INDEX orderindex ON slwcordertracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'(ORD_HDRNUMBER)'
					EXEC (@SqlCmd)
					SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
					INSERT @TEMP
					EXEC (@SqlCmd)
					IF((SELECT * FROM @TEMP) = 0)
					BEGIN
						SELECT @Result = 'Order does not exists'
						SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('
						+CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''orderheader'', '''+@Result+''',GETDATE(),GETDATE(),0)'
						EXEC (@SqlCmd)
					END
					ELSE
					BEGIN
						SELECT @Result = 'New order'
						SET @SqlCmd ='INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message, odt_createddate, odt_updateddate, odt_reviewed)
						SELECT '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+', o.mov_number, l.lgh_number, o.ord_hdrnumber,''orderheader'', '''+@Result+''', GETDATE(), GETDATE(), 0 FROM orderheader o, legheader l where o.mov_number =l.mov_number AND o.ord_hdrnumber ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
						EXEC (@SqlCmd)
					END
					DELETE FROM @TEMP
				END
				ELSE
					SELECT @Result = ' '

				--Workcycle StopsTracking	
				IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
				BEGIN
					SET @SqlCmd = 'DROP TABLE slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)
					EXEC(@SqlCmd)
				END
				IF(@StopCollection != ' ')
				BEGIN
					SET @SqlCmd = 'SELECT IDENTITY(int, 1,1) AS ID, ORD_HDRNUMBER, STP_NUMBER, STP_TYPE,   ' +@StopCollection+ ' INTO slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' FROM STOPS WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
					EXEC (@SqlCmd)
					SET @SqlCmd = 'CREATE INDEX stopsindex ON slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'(ORD_HDRNUMBER, STP_NUMBER)'
					EXEC(@SqlCmd)
					--SET @SqlCmd = 'SELECT COUNT(0) FROM slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
					SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
					INSERT @TEMP
					EXEC(@SqlCmd)
					IF((SELECT * FROM @TEMP) = 0)
					BEGIN
						SELECT @STOPRESULT = 'Stops - no record found'
						SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('
						+CONVERT(VARCHAR(50),@Ord_hdrnumber)+', ''stops'', '''+@STOPRESULT+''',GETDATE(),GETDATE(),0)'
						EXEC (@SqlCmd)
					END
					ELSE
					BEGIN
						SELECT @STOPRESULT = 'Stops - new record'
						SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message, odt_createddate, odt_updateddate, odt_reviewed) SELECT '
						+CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, s.stp_number,''stops'' , '''+@STOPRESULT+''',GETDATE(),GETDATE(),0 FROM stops s  WHERE s.ord_hdrnumber ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
						EXEC (@SqlCmd)
						--SET @SqlCmd = 'INSERT INTO orderdatatracking VALUES('+CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''stops'', '''+@STOPRESULT+''',''NA'',''NA'',''NA'',GETDATE(),GETDATE(),0)'
					END
					DELETE FROM @TEMP
				END
				ELSE
					SELECT @STOPRESULT = ' '

				--Freight Tracking	
				IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
				BEGIN
					SET @SqlCmd = 'DROP TABLE slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)
					EXEC(@SqlCmd)
				END
				IF(@FreightCollection != ' ')
				BEGIN
					SET @SqlCmd = 'SELECT IDENTITY(int, 1,1) AS ID, S.ORD_HDRNUMBER, S.STP_NUMBER, F.FGT_NUMBER, S.STP_TYPE, ' +@FreightCollection+ ' INTO slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+
					' FROM FREIGHTDETAIL F, STOPS S WHERE S.STP_NUMBER = F.STP_NUMBER AND ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
					EXEC (@SqlCmd)
					SET @SqlCmd = 'CREATE INDEX freightsindex ON slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'(ORD_HDRNUMBER,STP_NUMBER,FGT_NUMBER )'
					EXEC(@SqlCmd)
					SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
					INSERT @TEMP
					EXEC (@SqlCmd)
					IF((SELECT * FROM @TEMP) = 0)
					BEGIN
						SELECT @FREIGHTRESULT = 'Freights - no record found'
						SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('
						+CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''freightdetail'', '''+@FREIGHTRESULT+''', GETDATE(),GETDATE(),0)'
						EXEC (@SqlCmd)
					END
					ELSE
					BEGIN
						SELECT @FREIGHTRESULT = 'Freights - new record'
						SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
						CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, f.fgt_number,''freightdetail'' , '''+@FREIGHTRESULT+''',GETDATE(),GETDATE(),0 FROM stops s, freightdetail f  WHERE f.stp_number = s.stp_number AND s.ord_hdrnumber ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
						EXEC (@SqlCmd)
					END
					DELETE FROM @TEMP
				END			
				ELSE
					SELECT @FREIGHTRESULT = ' '

				---- Event Tracking	
				IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
				BEGIN
					SET @SqlCmd = 'DROP TABLE slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)
					EXEC(@SqlCmd)
				END
				IF(@EventCollection != ' ')
				BEGIN
					SET @SqlCmd = 'SELECT IDENTITY(int, 1,1) AS ID, E.ORD_HDRNUMBER, E.STP_NUMBER, S.STP_TYPE, E.EVT_NUMBER, ' +@EventCollection+ 
					' INTO slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' FROM EVENT E, STOPS S WHERE E.ORD_HDRNUMBER=S.ORD_HDRNUMBER AND
					E.STP_NUMBER=S.STP_NUMBER AND E.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
					EXEC (@SqlCmd)
					SET @SqlCmd = 'CREATE INDEX eventsindex ON slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' (ORD_HDRNUMBER,STP_NUMBER,EVT_NUMBER )'
					EXEC (@SqlCmd)
					--SET @SqlCmd = 'SELECT COUNT(0) FROM slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+ CONVERT(VARCHAR(50),@Ord_hdrnumber)
					SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
					INSERT @TEMP
					EXEC (@SqlCmd)
					IF((SELECT * FROM @TEMP) = 0)
					BEGIN
						SELECT @EVENTRESULT = 'Event - no record found'
						SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('+
						CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''event'', '''+@EVENTRESULT+''',GETDATE(),GETDATE(),0)'
						EXEC (@SqlCmd)
					END
					ELSE
					BEGIN
						SELECT @EVENTRESULT = 'Event - new record'
						SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
						CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, e.evt_number,''event'' , '''+@EVENTRESULT+''',GETDATE(),GETDATE(),0 FROM stops s, event e  WHERE e.stp_number = s.stp_number AND e.ord_hdrnumber = s.ord_hdrnumber AND e.ord_hdrnumber ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
						EXEC (@SqlCmd)
					END
					DELETE FROM @TEMP
				END
				ELSE
					SELECT @EVENTRESULT = ' '

				---- REFERENCENUMBER Tracking	
				IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
				BEGIN
					SET @SqlCmd = 'DROP TABLE slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)
					EXEC(@SqlCmd)
				END
				IF(@REFTYPECollection != ' ')
				BEGIN
					SET @SqlCmd = 'SELECT IDENTITY(int, 1,1) AS ID, ORD_HDRNUMBER, REF_NUMBER, REF_TABLE, REF_TYPE INTO slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' FROM REFERENCENUMBER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+
					' AND  REF_TYPE IN ('
					WHILE LEN(@REFNUMCollectionCopy) > 0 
					BEGIN --WHILE
						SET @Column_End = CHARINDEX(',', @REFNUMCollectionCopy)
						IF @Column_End = 0
						SET @Column_End = LEN(@REFNUMCollectionCopy) + 1
						SET @Column = LTRIM(RTRIM(LEFT(@REFNUMCollectionCopy, @Column_End - 1)))	
						SET @SqlCmd = @SqlCmd  +''''+@Column+''''+','			
						SET @REFNUMCollectionCopy = SUBSTRING(@REFNUMCollectionCopy, @Column_End + 1, 2000000000)
					END --WHILE
					SET @SqlCmd = LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ')'
					EXEC (@SqlCmd)
					SET @SQLCMD = 'CREATE INDEX refnumindex ON slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'(ORD_HDRNUMBER, REF_NUMBER)'
					EXEC (@SQLCMD)
					--SET @SqlCmd = 'SELECT COUNT(0) FROM slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)
					SET @SqlCmd = 'SELECT COUNT(0) FROM slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
					INSERT @TEMP
					EXEC (@SQLCMD)
					IF((SELECT * FROM @TEMP) = 0)
					BEGIN
						SELECT @REFRESULT = 'Referencenumber - no record found'
						SET @SqlCmd = 'INSERT INTO orderdatatracking ( ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('+
						CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''referencenumber'', '''+@REFRESULT+''',GETDATE(),GETDATE(),0)'
						EXEC (@SqlCmd)
					END
					ELSE
					BEGIN
						SELECT @REFRESULT = 'Referencenumber - new record'
						SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
						CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, r.ref_tablekey,''referencenumber'' , '''+@REFRESULT+''',GETDATE(),GETDATE(),0 FROM stops s, referencenumber r  WHERE  r.ord_hdrnumber = s.ord_hdrnumber AND r.ord_hdrnumber ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
						EXEC (@SqlCmd)
					END
					DELETE FROM @TEMP
					SET @REFNUMCollectionCopy = @REFTYPECollection
				END
				ELSE
					SELECT @REFRESULT = ' '
				SET @Initialize = 'N'
			END	

			ELSE IF @Initialize = 'N'
			BEGIN -- ELSE IF		
				DELETE FROM @TEMP
				-- SLWCORDERTRACKING BEGIN
				SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
				INSERT @TEMP
				EXEC (@SqlCmd)
				IF((SELECT * FROM @TEMP) = 0)
				BEGIN
					SELECT @Result = 'Order does not exists'
					SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('
					+CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''orderheader'', '''+@Result+''',GETDATE(),GETDATE(),0)'
					EXEC (@SqlCmd)					
					DELETE FROM @TEMP
				END
				ELSE
				BEGIN	
					DELETE FROM @TEMP		
					IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwcordertracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
					BEGIN
						SET @SqlCmd ='SELECT COUNT(0) FROM slwcordertracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)	
						INSERT @TEMP
						EXEC (@SqlCmd)		
						IF ((SELECT * FROM @TEMP) = 0)
						BEGIN
							SET @SqlCmd = 'INSERT INTO slwcordertracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' SELECT ORD_HDRNUMBER,  '		
							WHILE LEN(@OrderCollectionCopy) > 0
							BEGIN --WHILE
								SET @Column_End = CHARINDEX(',', @OrderCollectionCopy)
								IF @Column_End = 0
								SET @Column_End = LEN(@OrderCollectionCopy) + 1
								SET @Column = LTRIM(RTRIM(LEFT(@OrderCollectionCopy, @Column_End - 1)))
								SET @SqlCmd = @SqlCmd  + ' O.[' + @Column + '],'
								SET @OrderCollectionCopy = SUBSTRING(@OrderCollectionCopy, @Column_End + 1, 2000000000)
							END--WHILE
							SET @SqlCmd =  LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ' FROM ORDERHEADER O WHERE O.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
							EXEC(@SqlCmd)
							SELECT @Result = 'New order'
							SET @SqlCmd ='INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message, odt_createddate, odt_updateddate, odt_reviewed)
							SELECT '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+', o.mov_number, l.lgh_number, o.ord_hdrnumber,''orderheader'', '''+@Result+''', GETDATE(), GETDATE(), 0 FROM orderheader o, legheader l where o.mov_number =l.mov_number AND o.ord_hdrnumber ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
							EXEC (@SqlCmd)
							SET @OrderCollectionCopy = @OrderCollection
							DELETE FROM @TEMP
						END		
						ELSE
						BEGIN
							DELETE FROM @TEMP
							SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER O RIGHT JOIN slwcordertracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+
							'  OT ON OT.ORD_HDRNUMBER = O.ORD_HDRNUMBER WHERE  O.ORD_HDRNUMBER =' +CONVERT(VARCHAR(50),@ORD_HDRNUMBER)
							WHILE LEN(@OrderCollection) > 0
							BEGIN --WHILE
								SET @Column_End = CHARINDEX(',', @OrderCollection)
								IF @Column_End = 0
								SET @Column_End = LEN(@OrderCollection) + 1
								SET @Column = LTRIM(RTRIM(LEFT(@OrderCollection, @Column_End - 1)))--ISNULL(E.[evt_contact],0)
								SET @SqlCmd = @SqlCmd  + ' AND  ISNULL(O.[' + @Column + '],0)  =  ISNULL(OT.[' + @Column + ']' +',0)'
								SET @OrderCollection = SUBSTRING(@OrderCollection, @Column_End + 1, 2000000000)
								SET @InsrtSqlcmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message,odt_columnname, odt_oldvalue, odt_newvalue, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
								CONVERT(VARCHAR(50),@Ord_hdrnumber)+',o.mov_number,l.lgh_number, o.ord_hdrnumber,''Orderheader'', ''Orderchanged'',''' + @Column + ''', OT.['+CONVERT(VARCHAR(50),@Column)+'], O.['+CONVERT(VARCHAR(50),@Column)+'],GETDATE(),GETDATE(),0 FROM ORDERHEADER O, legheader l, slwcordertracking_'+
								CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' OT WHERE o.ord_hdrnumber = l.ord_hdrnumber AND OT.ORD_HDRNUMBER = O. ORD_HDRNUMBER AND OT.ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+' AND O.ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+' AND ISNULL(O.[' + @Column + '],0) !=  ISNULL(OT.[' + @Column + '],0)'
								EXEC(@InsrtSqlcmd)							
							END --WHILE
							INSERT @TEMP
							EXEC (@SqlCmd)							
							IF (SELECT * FROM @TEMP) = 0
							BEGIN
								SET @SqlCmd = 'DELETE FROM slwcordertracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
								EXEC (@SqlCmd)
								SET @SqlCmd = 'INSERT INTO slwcordertracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  SELECT O.ORD_HDRNUMBER,  '		
								WHILE LEN(@OrderCollectionCopy) > 0
								BEGIN --WHILE
									SET @Column_End = CHARINDEX(',', @OrderCollectionCopy)
									IF @Column_End = 0
									SET @Column_End = LEN(@OrderCollectionCopy) + 1
									SET @Column = LTRIM(RTRIM(LEFT(@OrderCollectionCopy, @Column_End - 1)))
									SET @SqlCmd = @SqlCmd  + ' O.[' + @Column + '],'
									SET @OrderCollectionCopy = SUBSTRING(@OrderCollectionCopy, @Column_End + 1, 2000000000)
								END--WHILE
								SET @SqlCmd =  LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ' FROM ORDERHEADER O WHERE O.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
								EXEC(@SqlCmd)
								SELECT @Result =  'ORDERCHANGED'
							END				
							ELSE
								SELECT @Result =  'NO CHANGES IN ORDER'
							DELETE FROM @TEMP
						END
					END		
					ELSE
						SELECT @Result = ' '
				END
				-- SLWCORDERTRACKING end
				--WCStopTracking BEGIN
				DELETE FROM @TEMP
				SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
				INSERT @TEMP
				EXEC (@SqlCmd)
				IF((SELECT * FROM @TEMP) = 0)
				BEGIN
					SELECT @STOPRESULT = 'Stops - no record found'
					SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('
					+CONVERT(VARCHAR(50),@Ord_hdrnumber)+', ''stops'', '''+@STOPRESULT+''',GETDATE(),GETDATE(),0)'
					EXEC (@SqlCmd)
					DELETE FROM @TEMP
				END
				ELSE
				BEGIN	
					DELETE FROM @TEMP
					IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
					BEGIN
						SET @SqlCmd = 'SELECT COUNT(0) FROM slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
						INSERT @TEMP
						EXEC (@SqlCmd)
						IF (SELECT * FROM @TEMP) = 0
						BEGIN
							SET @SqlCmd = 'INSERT INTO slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  SELECT S.ORD_HDRNUMBER, S.STP_NUMBER, S.STP_TYPE,  '		
							WHILE LEN(@StopCollectionCopy) > 0
							BEGIN --WHILE
								SET @Column_End = CHARINDEX(',', @StopCollectionCopy)
								IF @Column_End = 0
								SET @Column_End = LEN(@StopCollectionCopy) + 1
								SET @Column = LTRIM(RTRIM(LEFT(@StopCollectionCopy, @Column_End - 1)))
								SET @SqlCmd = @SqlCmd  + ' S.[' + @Column + '],'
								SET @StopCollectionCopy = SUBSTRING(@StopCollectionCopy, @Column_End + 1, 2000000000)
							END--WHILE
							SET @SqlCmd =  LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ' FROM STOPS S WHERE S.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
							EXEC(@SqlCmd)
							SET @StopCollectionCopy = @StopCollection
							SELECT @STOPRESULT ='Stops - new record'
							SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
							CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, s.stp_number,''stops'' , '''+@STOPRESULT+''',GETDATE(),GETDATE(),0 FROM stops s  WHERE s.ord_hdrnumber ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
							EXEC (@SqlCmd)
							DELETE FROM @temp
						END
						ELSE
						BEGIN
							-- PUP STOP CONDITION BEGIN
							DELETE FROM @temp													
							--EXEC @SqlCmd = dbo.SystemsLinkStopsCondition @Collection=@PUPStopCollection,@Type='''PUP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID;
							EXEC   dbo.SystemsLinkStopsCondition @Collection=@PUPStopCollection,@Type='''PUP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID,@ReturnVal = @ReturnVal output;
							SET @SqlCmd = @ReturnVal
							INSERT @TEMP
							EXEC (@SqlCmd)
							SET @ReturnVal = ' '
							IF (SELECT * FROM @TEMP) != 0
								SELECT @STOPRESULT =  'NO CHANGES IN STOPS'
							ELSE SELECT @STOPRESULT =  'PUP.STOP CHANGED'
							DELETE FROM @TEMP						
							-- PUP STOP CONDITION END
							-- DRP STOP CONDITION END
							DELETE FROM @temp					
							EXEC  dbo.SystemsLinkStopsCondition @Collection=@DRPStopCollection,@Type='''DRP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID,@ReturnVal = @ReturnVal output;
							--EXEC @SqlCmd = dbo.SystemsLinkStopsCondition @Collection=@DRPStopCollection,@Type='''DRP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID;
							SET @SqlCmd = @ReturnVal
							INSERT @TEMP
							EXEC (@SqlCmd)
							SET @ReturnVal = ' '
							IF (SELECT * FROM @TEMP) = 0
							BEGIN
								SELECT @STOPRESULT =  'DRP.STOP CHANGED'
							END
							DELETE FROM @TEMP						
							-- DRP STOP CONDITION END
							-- ALL STOP CONDITION BEGIN
							DELETE FROM @temp						
							--EXEC @SqlCmd = dbo.SystemsLinkStopsCondition @Collection=@ALLStopCollection,@Type='''PUP'',''DRP'',''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID;
							EXEC  dbo.SystemsLinkStopsCondition @Collection=@ALLStopCollection,@Type='''PUP'',''DRP'',''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID,@ReturnVal = @ReturnVal output;
							SET @SqlCmd = @ReturnVal
							INSERT @TEMP
							EXEC (@SqlCmd)
							SET @ReturnVal = ' '
							SET @SqlCmd ='SELECT COUNT(0) FROM STOPS S RIGHT JOIN slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+
							' ST ON ST.ORD_HDRNUMBER = S.ORD_HDRNUMBER WHERE S.STP_NUMBER = ST.STP_NUMBER AND S.STP_TYPE IN (''PUP'',''DRP'',''NONE'') AND S.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber) 
							INSERT @TEMP1
							EXEC (@SqlCmd)
							IF ((SELECT * FROM @TEMP)!=(SELECT * FROM @TEMP1))
							BEGIN
								SELECT @STOPRESULT =  'ALL.STOP CHANGED'
							END
							DELETE FROM @TEMP								
							-- ALL STOP CONDITION END
							-- NONE STOP CONDITION BEGIN
							DELETE FROM @TEMP
							SET @SqlCmd = 'SELECT COUNT(0) FROM  slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  ST WHERE ST.STP_TYPE =''NONE'' AND ST.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
							INSERT @TEMP
							EXEC (@SqlCmd)
							IF (SELECT * FROM @TEMP) = 0
							BEGIN
								--SELECT @STOPRESULT =  'NO CHANGES IN STOPS'
								DELETE FROM @TEMP
							END
							ELSE
							BEGIN
								DELETE FROM @TEMP
								--EXEC @SqlCmd = dbo.SystemsLinkStopsCondition @Collection=@NONEStopCollection,@Type='''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID;
								EXEC  dbo.SystemsLinkStopsCondition @Collection=@NONEStopCollection,@Type='''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID,@ReturnVal = @ReturnVal output;
								SET @SqlCmd = @ReturnVal
								INSERT @TEMP
								EXEC (@SqlCmd)
								SET @ReturnVal = ' '
								IF (SELECT * FROM @TEMP) = 0
								BEGIN
									SELECT @STOPRESULT =  'NONE.STOP CHANGED'
								END
							END
							DELETE FROM @TEMP
							-- NONE STOP CONDITION END 
							IF (@STOPRESULT <> 'Stops - new record')
							BEGIN
								SET @SqlCmd = 'DELETE FROM slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+ CONVERT(VARCHAR(50),@Ord_hdrnumber)
								EXEC (@SqlCmd)
								SET @SqlCmd = 'INSERT INTO slwcstoptracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  SELECT S.ORD_HDRNUMBER, S.STP_NUMBER, S.STP_TYPE,  '		
								WHILE LEN(@StopCollectionCopy) > 0
								BEGIN --WHILE
									SET @Column_End = CHARINDEX(',', @StopCollectionCopy)
									IF @Column_End = 0
									SET @Column_End = LEN(@StopCollectionCopy) + 1
									SET @Column = LTRIM(RTRIM(LEFT(@StopCollectionCopy, @Column_End - 1)))
									SET @SqlCmd = @SqlCmd  + ' S.[' + @Column + '],'
									SET @StopCollectionCopy = SUBSTRING(@StopCollectionCopy, @Column_End + 1, 2000000000)
								END--WHILE
								SET @SqlCmd =  LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ' FROM STOPS S WHERE S.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
								EXEC(@SqlCmd)
								SET @StopCollectionCopy = @StopCollection
							END			
						END	
					END		
					ELSE
						SELECT @STOPRESULT = ' '
				END
				--WCStopTracking END
				--WCFREIGHTTracking BEGIN
				DELETE FROM @TEMP
				SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
				INSERT @TEMP
				EXEC (@SqlCmd)
				IF((SELECT * FROM @TEMP) = 0)
				BEGIN
					SELECT @FREIGHTRESULT = 'Freights - no record found'
					SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('+
					CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''freightdetail'', '''+@FREIGHTRESULT+''', GETDATE(),GETDATE(),0)'
					EXEC (@SqlCmd)
					DELETE FROM @TEMP
				END
				ELSE
				BEGIN	
					DELETE FROM @TEMP
					IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
					BEGIN
						SET @SqlCmd = 'SELECT COUNT(0) FROM slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
						INSERT @TEMP
						EXEC (@SqlCmd)				
						IF (SELECT * FROM @TEMP) = 0
						BEGIN
							SET @SqlCmd = 'INSERT INTO slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  SELECT S.ORD_HDRNUMBER, S.STP_NUMBER, F.FGT_NUMBER, S.STP_TYPE,  '		
							WHILE LEN(@FREIGHTCollectionCopy) > 0
							BEGIN --WHILE 
								SET @Column_End = CHARINDEX(',', @FREIGHTCollectionCopy)
								IF @Column_End = 0
								SET @Column_End = LEN(@FREIGHTCollectionCopy) + 1
								SET @Column = LTRIM(RTRIM(LEFT(@FREIGHTCollectionCopy, @Column_End - 1)))
								SET @SqlCmd = @SqlCmd  + ' F.[' + @Column + '],'
								SET @FREIGHTCollectionCopy = SUBSTRING(@FREIGHTCollectionCopy, @Column_End + 1, 2000000000)
							END--WHILE
							SET @SqlCmd =  LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ' FROM STOPS S, FREIGHTDETAIL F WHERE S.STP_NUMBER = F.STP_NUMBER AND S.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
							EXEC(@SqlCmd)
							SET @FREIGHTCollectionCopy = @FREIGHTCollection
							SELECT @FREIGHTRESULT ='Freights - new record'
							SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
							CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, f.fgt_number,''freightdetail'' , '''+@FREIGHTRESULT+''',GETDATE(),GETDATE(),0 FROM stops s, freightdetail f  WHERE f.stp_number = s.stp_number AND s.ord_hdrnumber ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
							EXEC (@SqlCmd)
							DELETE FROM @TEMP
						END
						ELSE
						BEGIN
							DELETE FROM @TEMP
							-- PUP STOP-Freight CONDITION BEGIN				
							--EXEC @SqlCmd = dbo.[FnFreightsCondition] @Collection=@PUPFREIGHTCollection,@Type='''PUP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID; 
							EXEC  dbo.[SystemsLinkFreightsCondition] @Collection=@PUPFREIGHTCollection,@Type='''PUP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID, @ReturnVal = @ReturnVal OUTPUT;
							SET @SqlCmd = @ReturnVal 
							INSERT @TEMP
							EXEC (@SqlCmd)
							SET @ReturnVal = ' '
							IF (SELECT * FROM @TEMP) != 0
								SELECT @FREIGHTRESULT =  'NO CHANGES IN FREIGHT'
							ELSE SELECT @FREIGHTRESULT =  'PUP.FREIGHT CHANGED'
							DELETE FROM @TEMP				
							-- PUP STOP-Freight CONDITION END
							-- DRP STOP-Freight CONDITION BEGIN
							DELETE FROM @TEMP				
							--EXEC @SqlCmd = dbo.[FnFreightsCondition] @Collection=@DRPFREIGHTCollection,@Type='''DRP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID; 
							EXEC  dbo.[SystemsLinkFreightsCondition] @Collection=@DRPFREIGHTCollection,@Type='''DRP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID, @ReturnVal = @ReturnVal OUTPUT;
							SET @SqlCmd = @ReturnVal 
							INSERT @TEMP
							EXEC (@SqlCmd)		
							SET @ReturnVal = ' '				
							IF (SELECT * FROM @TEMP) = 0
							BEGIN
								SELECT @FREIGHTRESULT =  'DRP.FREIGHT CHANGED'
							END
							DELETE FROM @TEMP
							-- DRP STOP-Freight CONDITION END
							-- ALL STOP-Freight CONDITION BEGIN
							DELETE FROM @TEMP				
							--EXEC @SqlCmd = dbo.[FnFreightsCondition] @Collection=@ALLFREIGHTCollection,@Type='''PUP'',''DRP'',''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID; 
							EXEC  dbo.[SystemsLinkFreightsCondition] @Collection=@ALLFREIGHTCollection,@Type='''PUP'',''DRP'',''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID, @ReturnVal = @ReturnVal OUTPUT;
							SET @SqlCmd = @ReturnVal 
							INSERT @TEMP
							EXEC (@SqlCmd)
							SET @ReturnVal = ' '
							SET @SqlCmd ='SELECT COUNT(0) FROM FREIGHTDETAIL F JOIN STOPS S ON S.STP_NUMBER = F.STP_NUMBER RIGHT JOIN slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+
							' FT ON FT.STP_NUMBER = F.STP_NUMBER WHERE FT.STP_TYPE IN (''PUP'',''DRP'',''NONE'') AND FT.STP_NUMBER =F.STP_NUMBER AND FT.STP_NUMBER = S.STP_NUMBER AND S.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber) 	
							DELETE FROM @TEMP1
							INSERT @TEMP1	
							EXEC (@SqlCmd)				
							IF ((SELECT * FROM @TEMP)!= (SELECT * FROM @TEMP1))
							BEGIN
								SELECT @FREIGHTRESULT =  'ALL.FREIGHT CHANGED'
							END
							DELETE FROM @TEMP			
							-- ALL STOP-Freight CONDITION END
							-- NONE STOP-Freight CONDITION BEGIN
							DELETE FROM @TEMP
							SET @SqlCmd ='SELECT COUNT(0) FROM  slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+ ' FT WHERE FT.STP_TYPE = ''NONE'' AND FT.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
							INSERT @TEMP
							EXEC (@SqlCmd)
							IF (SELECT * FROM @TEMP) = 0
							BEGIN
								--SELECT @FREIGHTRESULT =  'NO CHANGES IN FREIGHT'
								DELETE FROM @TEMP
							END
							ELSE
							BEGIN
								DELETE FROM @TEMP
								--EXEC @SqlCmd = dbo.[FnFreightsCondition] @Collection=@NONEFREIGHTCollection,@Type='''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID;
								EXEC  dbo.[SystemsLinkFreightsCondition] @Collection=@NONEFREIGHTCollection,@Type='''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID, @ReturnVal = @ReturnVal OUTPUT;
								SET @SqlCmd = @ReturnVal
								INSERT @TEMP
								EXEC (@SqlCmd)	
								SET @ReturnVal = ' '
								IF (SELECT * FROM @TEMP) = 0
								BEGIN
									SELECT @FREIGHTRESULT =  'NONE.FREIGHT CHANGED'
								END
							END								
							DELETE FROM @TEMP
							-- NONE STOP-Freight CONDITION END 
							--	IF @FREIGHTRESULT <> 'NO CHANGES IN FREIGHT'  
							IF @FREIGHTRESULT <> 'Freights - new record'
							BEGIN	
								SET @SqlCmd = 'DELETE FROM slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)
								EXEC (@SqlCmd)
								SET @SqlCmd = 'INSERT INTO slwcfreighttracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  SELECT S.ORD_HDRNUMBER, F.STP_NUMBER, F.FGT_NUMBER, S.STP_TYPE,   '		
								WHILE LEN(@FREIGHTCollectionCopy) > 0
								BEGIN --WHILE
									SET @Column_End = CHARINDEX(',', @FREIGHTCollectionCopy)
									IF @Column_End = 0
									SET @Column_End = LEN(@FREIGHTCollectionCopy) + 1
									SET @Column = LTRIM(RTRIM(LEFT(@FREIGHTCollectionCopy, @Column_End - 1)))
									SET @SqlCmd = @SqlCmd  + ' F.[' + @Column + '],'
									SET @FREIGHTCollectionCopy = SUBSTRING(@FREIGHTCollectionCopy, @Column_End + 1, 2000000000)
								END--WHILE
								SET @SqlCmd =  LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ' FROM FREIGHTDETAIL F JOIN STOPS S ON S.STP_NUMBER = F.STP_NUMBER WHERE S.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
								EXEC(@SqlCmd)
								SET @FREIGHTCollectionCopy = @FREIGHTCollection
							END
						END	
					END	
					ELSE
						SELECT @FREIGHTRESULT = ' '
				END
				--WCFREIGHTTracking END
				--WCEvent BEGIN
				DELETE FROM @TEMP
				SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
				INSERT @TEMP
				EXEC (@SqlCmd)
				IF((SELECT * FROM @TEMP) = 0)
				BEGIN
					SELECT @EVENTRESULT = 'Event - no record found'
					SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('+
					CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''event'', '''+@EVENTRESULT+''',GETDATE(),GETDATE(),0)'					
					EXEC (@SqlCmd)
					DELETE FROM @TEMP
				END
				ELSE
				BEGIN	
					DELETE FROM @TEMP
					IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
					BEGIN
						SET @SqlCmd = 'SELECT COUNT(0) FROM slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)
						INSERT @TEMP
						EXEC (@SqlCmd)
						IF (SELECT * FROM @TEMP) = 0
						BEGIN
							SET @SqlCmd = 'INSERT INTO slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  SELECT E.ORD_HDRNUMBER, E.STP_NUMBER, S.STP_TYPE, E.EVT_NUMBER,  '		
							WHILE LEN(@EVENTCollectionCopy) > 0
							BEGIN --WHILE
								SET @Column_End = CHARINDEX(',', @EVENTCollectionCopy)
								IF @Column_End = 0
								SET @Column_End = LEN(@EVENTCollectionCopy) + 1
								SET @Column = LTRIM(RTRIM(LEFT(@EVENTCollectionCopy, @Column_End - 1)))
								SET @SqlCmd = @SqlCmd  + ' E.[' + @Column + '],'
								SET @EVENTCollectionCopy = SUBSTRING(@EVENTCollectionCopy, @Column_End + 1, 2000000000)
							END--WHILE
							SET @SqlCmd =  LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ' FROM STOPS S, EVENT E WHERE S.STP_NUMBER = E.STP_NUMBER AND S.ORD_HDRNUMBER = E.ORD_HDRNUMBER AND E.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
							EXEC(@SqlCmd)
							SET @EVENTCollectionCopy = @EVENTCollection
							SELECT @EVENTRESULT ='Event - new record'
							SET @SqlCmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
							CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, e.evt_number,''event'' , '''+@EVENTRESULT+''',GETDATE(),GETDATE(),0 FROM stops s, event e  WHERE e.stp_number = s.stp_number AND e.ord_hdrnumber = s.ord_hdrnumber AND e.ord_hdrnumber ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
							EXEC (@SqlCmd)
							DELETE FROM @TEMP				
						END
						ELSE
						BEGIN
							DELETE FROM @TEMP
							-- PUP STOP-EVENT CONDITION BEGIN				
							EXEC  dbo.[SystemsLinkEVENTSCondition] @Collection=@PUPEVENTCollection,@Type='''PUP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID, @ReturnVal = @ReturnVal OUTPUT;
							SET @SqlCmd = @ReturnVal
							INSERT @TEMP
							EXEC (@SqlCmd)
							SET @ReturnVal = ' '
							IF (SELECT * FROM @TEMP) != 0
							SELECT @EVENTRESULT =  'NO CHANGES IN EVENT'
							ELSE SELECT @EVENTRESULT =  'PUP.EVENT CHANGED'
							DELETE FROM @TEMP				
							-- PUP STOP-EVENT CONDITION END
							-- DRP STOP-EVENT CONDITION BEGIN
							DELETE FROM @TEMP				
							EXEC  dbo.[SystemsLinkEVENTSCondition] @Collection=@DRPEVENTCollection,@Type='''DRP''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID, @ReturnVal = @ReturnVal OUTPUT;
							SET @SqlCmd = @ReturnVal				
							INSERT @TEMP
							EXEC (@SqlCmd)	
							SET @ReturnVal = ' '					
							IF (SELECT * FROM @TEMP) = 0
							BEGIN
								SELECT @EVENTRESULT =  'DRP.EVENT CHANGED'
							END				
							DELETE FROM @TEMP
							-- DRP STOP-EVENT CONDITION END
							-- ALL STOP-EVENT CONDITION BEGIN
							DELETE FROM @TEMP			
							EXEC  dbo.[SystemsLinkEVENTSCondition] @Collection=@ALLEVENTCollection,@Type='''PUP'',''DRP'',''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID, @ReturnVal = @ReturnVal OUTPUT;
							SET @SqlCmd = @ReturnVal				
							INSERT @TEMP
							EXEC (@SqlCmd)	
							SET @ReturnVal = ' '	
							SET @SqlCmd = 'SELECT COUNT(0) FROM EVENT E JOIN STOPS S ON S.STP_NUMBER = E.STP_NUMBER RIGHT JOIN slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' ET ON ET.STP_NUMBER = E.STP_NUMBER 
							WHERE ET.STP_TYPE IN (''PUP'',''DRP'',''NONE'') AND ET.STP_NUMBER = E.STP_NUMBER AND e.evt_number = et.evt_number and E.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)					
							DELETE FROM @TEMP1
							INSERT @TEMP1
							EXEC (@SqlCmd)
							IF ((SELECT * FROM @TEMP)!= (SELECT * FROM @TEMP1))
							BEGIN
								SELECT @EVENTRESULT =  'ALL.EVENT CHANGED'
							END
							DELETE FROM @TEMP				
							-- ALL STOP-EVENT CONDITION END
							-- NONE STOP-EVENT CONDITION BEGIN
							DELETE FROM @TEMP
							SET @SqlCmd ='SELECT COUNT(0) FROM  slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  ET WHERE ET.STP_TYPE = ''NONE'' AND ET.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
							INSERT @TEMP
							EXEC (@SqlCmd)
							IF (SELECT * FROM @TEMP)= 0
							BEGIN
								--SELECT @EVENTRESULT =  'NO CHANGES IN EVENTS'
								DELETE FROM @TEMP
							END
							ELSE
							BEGIN
								DELETE FROM @TEMP
								EXEC  dbo.[SystemsLinkEVENTSCondition] @Collection=@NONEEVENTCollection,@Type='''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID, @ReturnVal = @ReturnVal OUTPUT;
								--EXEC @SqlCmd = dbo.[FnEVENTsCondition] @Collection=@NONEEVENTCollection,@Type='''NONE''',@ORD_HDRNUMBER=@ORD_HDRNUMBER,@WORKFLOWTEMPLATEID = @WORKFLOWTEMPLATEID;
								SET @SqlCmd = @ReturnVal				
								INSERT @TEMP
								EXEC (@SqlCmd)	
								SET @ReturnVal = ' '					
								IF (SELECT * FROM @TEMP)= 0
								BEGIN
									SELECT @EVENTRESULT =  'NONE.EVENT CHANGED'
								END
							END
							DELETE FROM @TEMP			
							-- NONE STOP-EVENT CONDITION END 
							IF @EVENTRESULT <> 'Event - new record'
							BEGIN	
								SET @SqlCmd = 'DELETE FROM slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+ CONVERT(VARCHAR(50),@Ord_hdrnumber)				
								EXEC (@SqlCmd)
								SET @SqlCmd = 'INSERT INTO slwceventtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  SELECT E.ORD_HDRNUMBER, E.STP_NUMBER, S.STP_TYPE, E.EVT_NUMBER,  '		
								WHILE LEN(@EVENTCollectionCopy) > 0
								BEGIN --WHILE
									SET @Column_End = CHARINDEX(',', @EVENTCollectionCopy)
									IF @Column_End = 0
									SET @Column_End = LEN(@EVENTCollectionCopy) + 1
									SET @Column = LTRIM(RTRIM(LEFT(@EVENTCollectionCopy, @Column_End - 1)))
									SET @SqlCmd = @SqlCmd  + ' E.[' + @Column + '],'
									SET @EVENTCollectionCopy = SUBSTRING(@EVENTCollectionCopy, @Column_End + 1, 2000000000)
								END--WHILE
								SET @SqlCmd =  LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ' FROM EVENT E JOIN STOPS S ON S.STP_NUMBER = E.STP_NUMBER AND S.ORD_HDRNUMBER = E.ORD_HDRNUMBER WHERE E.ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
								EXEC(@SqlCmd)
								SET @EVENTCollectionCopy = @EVENTCollectionCopy
							END
						END	
					END
					ELSE
						SELECT @EVENTRESULT = ' '
				END
				--WCEvent END
				DELETE FROM @TEMP
				SET @SqlCmd = 'SELECT COUNT(0) FROM ORDERHEADER WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
				INSERT @TEMP
				EXEC (@SqlCmd)
				IF((SELECT * FROM @TEMP) = 0)
				BEGIN
					SELECT @REFRESULT = 'Referencenumber - no record found'
					DELETE FROM @TEMP
					SET @SqlCmd = 'INSERT INTO orderdatatracking ( ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('+
					CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''referencenumber'', '''+@REFRESULT+''',GETDATE(),GETDATE(),0)'
					EXEC (@SqlCmd)
				END
				ELSE
				BEGIN	
					DELETE FROM @TEMP
					IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)))
					BEGIN
					--ReferenceNumber Tracking Begin
						SET @SqlCmd = 'SELECT COUNT(0) FROM slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
						INSERT @TEMP
						EXEC (@SqlCmd)
						IF (SELECT * FROM @TEMP) = 0
						BEGIN
							SET @SqlCmd = 'INSERT INTO slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  SELECT ORD_HDRNUMBER, REF_NUMBER, REF_TABLE, REF_TYPE FROM REFERENCENUMBER  WHERE '		
							WHILE LEN(@REFNUMCollectionCopy) > 0
							BEGIN --WHILE
								SET @Column_End = CHARINDEX(',', @REFNUMCollectionCopy)
								IF @Column_End = 0
								SET @Column_End = LEN(@REFNUMCollectionCopy) + 1
								SET @Column = LTRIM(RTRIM(LEFT(@REFNUMCollectionCopy, @Column_End - 1)))
								SET @SqlCmd = @SqlCmd  + ' REF_TYPE  = ''' + @Column + ''' AND  '
								SET @REFNUMCollectionCopy = SUBSTRING(@REFNUMCollectionCopy, @Column_End + 1, 2000000000)
							END--WHILE
							SET @SqlCmd = @SqlCmd + ' ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
							EXEC(@SqlCmd)
							SET @REFNUMCollectionCopy = @REFTYPECollection
							SELECT @REFRESULT ='REFERENCENUMBER - NEW RECORD'				
							DELETE FROM @TEMP
							SET @SqlCmd = 'SELECT COUNT(0) FROM slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
							INSERT @TEMP
							EXEC (@SqlCmd)
							IF (SELECT * FROM @TEMP) = 0				
							SELECT @REFRESULT ='Referencenumber - no record found'	
							SET @SqlCmd = 'INSERT INTO orderdatatracking ( ord_hdrnumber,odt_tablename,odt_message,odt_createddate,odt_updateddate,odt_reviewed) VALUES('+
							CONVERT(VARCHAR(50),@Ord_hdrnumber)+',''referencenumber'', '''+@REFRESULT+''',GETDATE(),GETDATE(),0)'
							EXEC (@SqlCmd)								
						END
						ELSE
						BEGIN
							DELETE FROM @TEMP
							SET @SqlCmd = 'SELECT COUNT(0) FROM REFERENCENUMBER R RIGHT JOIN slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  RT ON RT.ORD_HDRNUMBER = R.ORD_HDRNUMBER 
							WHERE R.REF_TABLE=RT.REF_TABLE AND R.REF_NUMBER=RT.REF_NUMBER AND R.REF_TYPE=RT.REF_TYPE AND R.ORD_HDRNUMBER =' +CONVERT(VARCHAR(50),@ORD_HDRNUMBER)+'  AND  R.REF_TYPE IN ('
							WHILE LEN(@REFTYPECollection) > 0
							BEGIN --WHILE
								SET @Column_End = CHARINDEX(',', @REFTYPECollection)
								IF @Column_End = 0
								SET @Column_End = LEN(@REFTYPECollection) + 1
								SET @Column = LTRIM(RTRIM(LEFT(@REFTYPECollection, @Column_End - 1)))
								--SET @SqlCmd = @SqlCmd  + ' AND  R.REF_TYPE  = ''' + @Column + ''' '
								SET @SqlCmd = @SqlCmd  +''''+@Column+''''+','
								SET @REFTYPECollection = SUBSTRING(@REFTYPECollection, @Column_End + 1, 2000000000)
								SET @InsrtSqlcmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message,odt_columnname, odt_oldvalue, odt_newvalue, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+
								CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, r.ref_tablekey,''referencenumber'', ''Reference number changed'',''' + @Column + ''', RT.['+CONVERT(VARCHAR(50),@Column)+'], R.['+CONVERT(VARCHAR(50),@Column)+'],GETDATE(),GETDATE(),0 FROM REFERENCENUMBER R,stops s, slwcrefnumtracking_'+
								CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' RT WHERE r.ord_hdrnumber = s.ord_hdrnumber AND RT.ORD_HDRNUMBER = R.ORD_HDRNUMBER AND R.REF_TABLE=RT.REF_TABLE AND R.REF_NUMBER=RT.REF_NUMBER AND R.REF_TYPE=RT.REF_TYPE AND R.ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+' AND ISNULL(R.[' + @Column + '],0) !=  ISNULL(RT.[' + @Column + '],0)'
								EXEC(@InsrtSqlcmd)	
							END --WHILE
							SET @SqlCmd = LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ')'
							INSERT @TEMP
							EXEC (@SqlCmd)						
							IF (SELECT * FROM @TEMP) = 0
							BEGIN
								DELETE FROM @TEMP
								SET @SqlCmd ='DELETE FROM slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  WHERE ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)
								EXEC (@SqlCmd)
								SET @SqlCmd = 'INSERT INTO slwcrefnumtracking_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+'  SELECT ORD_HDRNUMBER, REF_NUMBER, REF_TABLE, REF_TYPE FROM REFERENCENUMBER  WHERE  REF_TYPE IN ( '		
								WHILE LEN(@REFNUMCollectionCopy) > 0
								BEGIN --WHILE
									SET @Column_End = CHARINDEX(',', @REFNUMCollectionCopy)
									IF @Column_End = 0
									SET	@Column_End = LEN(@REFNUMCollectionCopy) + 1
									SET @Column = LTRIM(RTRIM(LEFT(@REFNUMCollectionCopy, @Column_End - 1)))
									SET @SqlCmd = @SqlCmd  +''''+@Column+''''+','
									SET @REFNUMCollectionCopy = SUBSTRING(@REFNUMCollectionCopy, @Column_End + 1, 2000000000)
								END--WHILE					 
								SET @SqlCmd = LEFT(@SqlCmd, LEN(@SqlCmd) - 1) + ') ORD_HDRNUMBER ='+CONVERT(VARCHAR(50),@Ord_hdrnumber)+''
								EXEC(@SqlCmd)
								SELECT @REFRESULT = 'REFERENCE NUMBER CHANGED'
							END
							ELSE
								SELECT @REFRESULT =  'NO CHANGES IN REFERENCE NUMBER'
							DELETE FROM @TEMP
						END
					END	
					ELSE
						SELECT @REFRESULT = ' '
				END
				--ReferenceNumber Tracking End	
			END 
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		SET @ErrorNumber  = ERROR_NUMBER()
		SET @ErrorLine  = ERROR_LINE()
		SET @ErrorMessage  = ERROR_MESSAGE()
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		SET @Result = ' '
		SET @STOPRESULT =''
		SET @FREIGHTRESULT = ' '
		SET @EVENTRESULT = ' '
		SET @REFRESULT = ' '
		--DECLARE @ErrorNumber INT = ERROR_NUMBER();
		--DECLARE @ErrorLine INT = ERROR_LINE();
		--DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		--DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		--DECLARE @ErrorState INT = ERROR_STATE();
		--   PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		--   PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
		--PRINT 'Actual error message: ' + CAST(@ErrorMessage AS VARCHAR(1000));
		-- RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END

GO
GRANT EXECUTE ON  [dbo].[SYSTEMSLINK_ORDERDETAILSCHANGED_TRANS] TO [public]
GO

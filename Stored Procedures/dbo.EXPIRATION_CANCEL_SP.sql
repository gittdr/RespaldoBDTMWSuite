SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
----------------------------------
--- TMT AMS from TMWSYSTEMS

--- CHANGED 1/9/2013  MB PCR:8455
--- CHANGED 04/04/2011 MH
--- CHANGED 01/06/2010 MB
--- CHANGED 02/08/2007 MB
--- CHANGED 09/08/2006 MB
----------------------------------
CREATE   PROCEDURE [dbo].[EXPIRATION_CANCEL_SP]
       @EXP_KEY INT
      ,@EXP_ISPM SMALLINT = 0
      ,@COMPLETE_DATE DATETIME = NULL
      ,@EXP_ORDERID INT = NULL
      ,@COMPCODE [VARCHAR](12) = NULL
      ,@COMPCDKEY [VARCHAR](12) = NULL
AS 
       BEGIN
             DECLARE @DEBUG INTEGER
             SET @DEBUG = 0	-- 0 = Off, 1 = On

             IF @DEBUG = 1 
                PRINT 'EXPIRATION_CANCEL_SP'
             IF @DEBUG = 1 
                PRINT 'ORDER:' + CONVERT(VARCHAR(20), @EXP_ORDERID)
             IF @DEBUG = 1 
                PRINT 'COMPCODE:' + @COMPCODE
             IF @DEBUG = 1 
                PRINT 'EXP_ISPM:' + CONVERT(VARCHAR(20), ISNULL(@EXP_ISPM, 0))

             DECLARE @COMPLDATE DATETIME
             SET @COMPLDATE = GETDATE()
    
             IF ISNULL(@EXP_ISPM, 0) = 0  -- It is a canceled PM.
                BEGIN
                      IF @DEBUG = 1 
                         PRINT 'Deleting PM'        
                      IF EXISTS ( SELECT  [EXP_KEY]
                                  FROM    [DBO].[EXPIRATION]
                                  WHERE   [EXP_KEY] = @EXP_KEY ) 
                         BEGIN
                               DELETE [DBO].[EXPIRATION]
                               WHERE  [EXP_KEY] = @EXP_KEY
                               DELETE TMT_Expirations
                               WHERE  [EXP_KEY] = @EXP_KEY
                         END
                END
             ELSE 
                BEGIN
                      IF ISNULL(@Compcode, '') > '' 
                         BEGIN
                               IF @Debug = 1 
                                  PRINT 'Updating A Specific Pm On An Order To Not Complete'
			-- Section Canceled, Make Any Assoicated Pms Active Again.             
                               UPDATE [Dbo].[Expiration]
                               SET    [Exp_Completed] = 'N'
                                     ,[Exp_Compldate] = @Compldate
                                     ,[Exp_Updateby] = 'Ams Interface'
                                     ,[Exp_Updateon] = GETDATE()
                               WHERE  [Exp_Key] IN ( SELECT Exp_Key
                                                     FROM   Tmt_Expirations
                                                     WHERE  Exp_Orderid = @Exp_Orderid
                                                            AND [Exp_Code] <> 'Inshop'
                                                            AND Exp_Compcode = @Compcode
                                                            AND Exp_Codekey = @Compcdkey )

                               UPDATE Tmt_Expirations
                               SET    [Exp_Completed] = 'N'
                                     ,[Exp_Compldate] = @Compldate
                               WHERE  [Exp_Key] IN ( SELECT Exp_Key
                                                     FROM   Tmt_Expirations
                                                     WHERE  Exp_Orderid = @Exp_Orderid
                                                            AND [Exp_Code] <> 'Inshop'
                                                            AND Exp_Compcode = @Compcode
                                                            AND Exp_Codekey = @Compcdkey )
                         END
                      ELSE	-- Canceled Order
                         BEGIN
                                           IF @Debug = 1 
                                           PRINT 'Start of Else'
                                           
                                           
			-- Delete The Inshop Expiration.
			-- Find Out If There Is An Expiration To Delete. If Not, Then Assume It's Already Been Done.

			
                               IF ( SELECT  COUNT(1)
                                    FROM    Tmt_Expirations
                                    WHERE   [Exp_Key] IN ( SELECT Exp_Key
                                                           FROM   Tmt_Expirations
                                                           WHERE  Exp_Orderid = @Exp_Orderid
                                                                  AND [Exp_Code] IN ('Inshop','PEND' )) ) > 0 
                                  BEGIN
                                        IF @Debug = 1 
                                           PRINT 'Deleting Inshop Expiration'
                                        DELETE  [Dbo].[Expiration]
                                        WHERE   [Exp_Key] IN ( SELECT Exp_Key
                                                               FROM   Tmt_Expirations
                                                               WHERE  Exp_Orderid = @Exp_Orderid
                                                                      AND [Exp_Code] IN ('Inshop','PEND' ) )
                                        DELETE  Tmt_Expirations
                                        WHERE   [Exp_Key] IN ( SELECT Exp_Key
                                                               FROM   Tmt_Expirations
                                                               WHERE  Exp_Orderid = @Exp_Orderid
                                                                      AND [Exp_Code] IN ('Inshop','PEND' ) )


                                        IF @Debug = 1 
                                           PRINT 'The Ro Was Canceled, Make Any Assoicated Pms Active Again'
				-- The Ro Was Canceled, Make Any Assoicated Pms Active Again.             
                                        UPDATE  [Dbo].[Expiration]
                                        SET     [Exp_Completed] = 'N'
                                               ,[Exp_Compldate] = @Compldate
                                               ,[Exp_Updateby] = 'Ams Interface'
                                               ,[Exp_Updateon] = GETDATE()
                                        WHERE   [Exp_Key] IN ( SELECT Exp_Key
                                                               FROM   Tmt_Expirations
                                                               WHERE  Exp_Orderid = @Exp_Orderid
                                                                      AND [Exp_Code] <> 'Inshop' )

                                        UPDATE  Tmt_Expirations
                                        SET     [Exp_Completed] = 'N'
                                               ,[Exp_Compldate] = @Compldate
                                        WHERE   [Exp_Key] IN ( SELECT Exp_Key
                                                               FROM   Tmt_Expirations
                                                               WHERE  Exp_Orderid = @Exp_Orderid
                                                                      AND [Exp_Code] <> 'Inshop' )
                                  END
                         END
                END
    --EXEC [dbo].[TRC_EXPSTATUS] @EXP_KEY 
    
       END

GO
GRANT EXECUTE ON  [dbo].[EXPIRATION_CANCEL_SP] TO [public]
GO

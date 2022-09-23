SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
----------------------------------
--- TMT AMS from TMWSYSTEMS
--- VERSION 12.30.00 SQL SCRIPT
--- TMWSuite1230_Script1.sql
--- CHANGED 04/04/2011 MH
--  changed 01/01/2011 mh
--- Changed 05/05/2006 MB
----------------------------------
CREATE PROC [dbo].[EXPIRATION_UPDATE_SP]
       @EXP_KEY INT
      ,@EXP_PRIORITY VARCHAR(6)
      ,@EXP_COMPLDATE DATETIME
AS 
       DECLARE @DEBUG INTEGER
       SET @DEBUG = 0	-- 0 = Off, 1 = On

       IF @DEBUG = 1 
          PRINT 'EXPIRATION_UPDATE_SP'

       IF ISNULL(@EXP_PRIORITY, '') <> '' 
          BEGIN
                UPDATE  EXPIRATION
                SET     EXP_PRIORITY = @EXP_PRIORITY
                       ,[exp_updateby] = 'AMS Interface'
                       ,[exp_updateon] = GETDATE()
                WHERE   EXP_KEY = @EXP_KEY
                UPDATE  TMT_Expirations
                SET     EXP_PRIORITY = @EXP_PRIORITY
                WHERE   EXP_KEY = @EXP_KEY
          END
       IF ISNULL(@EXP_COMPLDATE, '') <> '' 
          BEGIN
                UPDATE  EXPIRATION
                SET     EXP_COMPLDATE = @EXP_COMPLDATE
                       ,[exp_updateby] = 'AMS Interface'
                       ,[exp_updateon] = GETDATE()
                WHERE   EXP_KEY = @EXP_KEY
                UPDATE  TMT_Expirations
                SET     EXP_COMPLDATE = @EXP_COMPLDATE
                WHERE   EXP_KEY = @EXP_KEY
          END


GO
GRANT EXECUTE ON  [dbo].[EXPIRATION_UPDATE_SP] TO [public]
GO

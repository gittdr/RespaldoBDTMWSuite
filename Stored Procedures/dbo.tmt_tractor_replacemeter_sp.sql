SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
----------------------------------
--- TMT AMS from TMWSYSTEMS
--- VERSION 12.30.00 SQL SCRIPT
--- TMWSuite1230_Script1.sql
--- Changed 05/05/2006 MB
----------------------------------
CREATE PROC [dbo].[tmt_tractor_replacemeter_sp]
@trc_number VARCHAR(8)
,@trc_currenthub INT
AS
IF ISNULL(@trc_currenthub, 0) <> 0
UPDATE  tractorprofile
SET     trc_currenthub = @trc_currenthub
WHERE   trc_number = @trc_number
GO
GRANT EXECUTE ON  [dbo].[tmt_tractor_replacemeter_sp] TO [public]
GO

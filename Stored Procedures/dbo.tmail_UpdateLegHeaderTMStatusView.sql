SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateLegHeaderTMStatusView] @sLegNum Varchar(10), 
						    	   @sOrderNum Varchar(12), 
						    	   @sMoveNum Varchar(10), 
						    	   @sTractor varchar(13), 
								   @sOutStatus varchar(6),
								   @sLghFlags varchar(15),
								   @sNoOverride varchar(15)	-- See definition in tmail_updatelegheadertmstatusview
AS

exec tmail_UpdateLegHeaderTMStatusView2 @sLegNum, 
						    	   @sOrderNum, 
						    	   @sMoveNum, 
						    	   @sTractor, 
								   @sOutStatus,
								   @sLghFlags,
								   @sNoOverride,
								   '' --New flags field blank
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateLegHeaderTMStatusView] TO [public]
GO

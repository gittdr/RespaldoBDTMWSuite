SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_create_expiration3] (@EqpType char(3), 
@EqpID varchar(13), 
@Drv varchar(13), 
@Trc varchar(13), 
@ReasonCode varchar(6), 
@ReturnDate varchar(30), 
@ReturnTime varchar(30), 
@OutDate varchar(30), 
@OutTime varchar(30), 
@Description varchar(255), 
@Priority varchar(6), 
@city varchar(18), 
@state varchar(6))

AS
	exec dbo.tmail_create_expiration4 @EqpType, @EqpID, @Drv, @Trc, @ReasonCode, @ReturnDate, @ReturnTime, @OutDate, @OutTime, '', '1','','','UNKNOWN'
	
	
GO
GRANT EXECUTE ON  [dbo].[tmail_create_expiration3] TO [public]
GO

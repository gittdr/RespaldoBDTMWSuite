SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[tmail_create_expiration] (@EqpType char(3), @EqpID varchar(13), @Drv varchar(13), @Trc varchar(13), 
@ReASonCode varchar(6), @ReturnDate varchar(30), @ReturnTime varchar(30), @OutDate varchar(30), @OutTime varchar(30))

AS
	EXEC dbo.tmail_create_expiration2 @EqpType, @EqpID, @Drv, @Trc, @ReASonCode, @ReturnDate, @ReturnTime, @OutDate, @OutTime, '', '1'

GO
GRANT EXECUTE ON  [dbo].[tmail_create_expiration] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Insert_Message]
				@Type int,
				@Status int,
				@Priority int,
				@ReplyFormID int,
				@ReplyPriority int,
				@Receipt int,
				@FromName varchar(50),
				@FromType int,
				@DTSent datetime,
				@Folder int,
				@DTReceived datetime,
				@Subject varchar(255),
				@Contents text,
				@DeliverTo varchar(50),
				@DeliverToType int,
				@Position varchar(50),
				@PositionZip varchar(10),
				@DTPosition datetime,
				@Latitude float,
				@Longitude float,
				@Odometer int,
				@NLCPosition varchar(50),
				@NLCPositionZip varchar(10),
				@DeliveryKey int,
				@NewSN int OUT
AS
--PTS 84336 RRS: Created PTS as part of PositionServer performance enhancements
SET NOCOUNT ON

INSERT INTO tblMessages (
			Type,
			Status,
			Priority,
			FromName,
			FromType,				--5

			DTSent,
			DTReceived,
			Folder,
			Subject,
			Contents,				--10

			DeliverTo,
			DeliverToType,		
			Receipt,
			DeliveryKey,
			Position,				--15

			PositionZip,
			NLCPosition,			
			NLCPositionZip,
			Latitude,
			Longitude,				--20

			DTPosition, 			
			ReplyFormID,
			ReplyPriority,
			Odometer)				

VALUES(		@Type,
			@Status,
			@Priority,
			@FromName,
			@FromType,			--5

			@DTSent,
			@DTReceived,
			@Folder,
			@Subject,
			@Contents,			--10

			@DeliverTo,
			@DeliverToType,		
			@Receipt,
			@DeliveryKey,
			@Position,			--15

			@PositionZip,
			@NLCPosition,			
			@NLCPositionZip,
			@Latitude,
			@Longitude,			--20

			@DTPosition,
			@ReplyFormID, 			
			@ReplyPriority,
			@Odometer)

SELECT @NewSN = @@IDENTITY	-- Get the SN of the new record
RETURN @NewSN
GO
GRANT EXECUTE ON  [dbo].[tm_Insert_Message] TO [public]
GO

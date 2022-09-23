SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_xmit_pnet_media_data]
		@FileName VARCHAR(50),
		@Packet INT = NULL,
		@Total INT = NULL,
		@Finished BIT = NULL,
		@DateCreated DATETIME = NULL,
		@DateReceived DATETIME = NULL,
		@Data VARBINARY(MAX) = NULL,
		@DataFormat varchar(12) = NULL,
		@Size INT = NULL,
		@AssetName varchar(50) = NULL,
		@lgh_number INT = NULL,
		@stp_number INT = NULL,
		@ExtraData VARCHAR(50) = NULL

AS


/**
 * 
 * NAME:
 * dbo.tmail_xmit_pnet_media_data
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Inserts a media record of an image or a signature into MediaData
 *
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * none.
 *
 * 
 * REVISION HISTORY:
 * 09.02.2015 – PTS85567 - Abdullah Binghunaiem – Initial Creation
 *
 **/

SET NOCOUNT ON

DECLARE 
	@exists INT,
	@dataExists VARBINARY(MAX)

BEGIN
	
	SELECT @exists = (SELECT COUNT(*) FROM MediaData WHERE FileName=@fileName)

	IF ISNULL(@exists, 0) > 0
	BEGIN
		
		SELECT @dataExists = (SELECT MediaData.Data FROM MediaData WHERE Filename=@FileName)

		-- If we have no data, update it.
		IF @dataExists IS NULL
		BEGIN
			UPDATE MediaData SET Packet = @Packet, Total = @Total, Finished = @Finished, Data = @data, Size = @Size WHERE FileName=@fileName
		END
		ELSE
		BEGIN
			-- Otherwise, add to the data, IFF the current data on the column does not match the new data
			IF @dataExists <> @Data
			BEGIN
				UPDATE MediaData SET Packet = @Packet, Total = @Total, Finished = @Finished, Data = Data + @data, Size = @Size WHERE FileName=@fileName
			END
			-- If it matches, discard it.
		END
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[MediaData] (
			FileName,
			Packet,
			Total,
			Finished,
			DateCreated,
			DateReceived,
			Data,
			DataFormat,
			Size,
			AssetName,
			lgh_number,
			stp_number,
			ExtraData)
		VALUES (
			@FileName,
			@Packet,
			@Total,
			@Finished,
			@DateCreated,
			@DateReceived,
			@Data,
			@DataFormat,
			@Size,
			@AssetName,
			@lgh_number,
			@stp_number,
			@ExtraData)
	END

	
END
GO
GRANT EXECUTE ON  [dbo].[tmail_xmit_pnet_media_data] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[PNMPayload]
AS
SELECT        FileName, Packet, Total, Finished, DateCreated, DateReceived, Data, DataFormat, Size, AssetName, lgh_number, stp_number, SN
FROM            dbo.MediaData
GO
GRANT DELETE ON  [dbo].[PNMPayload] TO [public]
GO
GRANT INSERT ON  [dbo].[PNMPayload] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PNMPayload] TO [public]
GO
GRANT SELECT ON  [dbo].[PNMPayload] TO [public]
GO
GRANT UPDATE ON  [dbo].[PNMPayload] TO [public]
GO

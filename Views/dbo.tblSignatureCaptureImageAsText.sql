SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[tblSignatureCaptureImageAsText]
as
/**
 
NAME:
dbo.tblSignatureCaptureImageAsText

TYPE:
View

DESCRIPTION:
sql view that converts the varbinary(max) image to a varchar(max) representation that is insertable and updatable

Change Log: 
rwolfe init 2015/11/30

 **/
select SN,SCD_SN, imagename, Cast(signatureimage as varchar(max)) as signatureimage from tblSignatureCaptureImage
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tblSignatureCaptureImageAsText_it] on [dbo].[tblSignatureCaptureImageAsText]
INSTEAD OF INSERT
AS
BEGIN
  INSERT INTO tblSignatureCaptureImage
       select SCD_SN, imagename, Cast(signatureimage as varbinary(max))
       FROM inserted
END;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tblSignatureCaptureImageAsText_ut] on [dbo].[tblSignatureCaptureImageAsText]
INSTEAD OF UPDATE
AS
BEGIN
	update tblSignatureCaptureImage set 
			SCD_SN = sub.SCD_SN, 
			imagename = sub.imagename, 
			signatureimage = Cast(sub.signatureimage as varbinary(max)) 
		from (select SN, SCD_SN, imagename, signatureimage as signatureimage FROM inserted) sub 
			where tblSignatureCaptureImage.SN = sub.sn
END;
GO
GRANT DELETE ON  [dbo].[tblSignatureCaptureImageAsText] TO [public]
GO
GRANT INSERT ON  [dbo].[tblSignatureCaptureImageAsText] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblSignatureCaptureImageAsText] TO [public]
GO
GRANT SELECT ON  [dbo].[tblSignatureCaptureImageAsText] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblSignatureCaptureImageAsText] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInitMenu]
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	CREATE TABLE #MenuPages (
		MenuSN int ,
		MenuSort int ,
		MenuCaption varchar (40),
		MenuCaptionFull varchar (255),
		MenuSystem int  ,
		MenuCustomProcess int ,
		MenuCustomPageTable varchar (30),
		PageSN int ,
		PageSort int ,
		PageCaption varchar (50),
		PageCaptionFull varchar (255),
		PagePassword varchar (30),
		PageURL varchar (255),
		PageShowTime int  
	) 
	INSERT INTO #MenuPages 
	EXEC MetricFillMenu

	DELETE #MenuPages WHERE ISNULL(MenuSN, 0) = 0 
	SELECT * FROM #MenuPages
GO
GRANT EXECUTE ON  [dbo].[MetricInitMenu] TO [public]
GO

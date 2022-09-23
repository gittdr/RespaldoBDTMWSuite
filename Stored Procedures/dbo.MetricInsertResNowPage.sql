SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricInsertResNowPage] (
	@MenuSectionSN int
	,@Active int
	,@Sort int
	,@ShowTime int
	,@Caption varchar(50)
	,@CaptionFull varchar(255)

	,@PageType varchar(30) = ''
	,@PageURL varchar(255) = ''
	,@CategoryCode varchar(30) = ''
	,@MetricCategorySN int = -1
)
AS
	SET NOCOUNT ON

	IF @PageType = '' AND @CategoryCode = '' AND @MetricCategorySN = -1
	BEGIN
		INSERT INTO ResNowPage (MenuSectionSN, Active, Sort, ShowTime, Caption, CaptionFull, PageType, PageURL, PagePassword) 
		VALUES (@MenuSectionSN, @Active, @Sort, @ShowTime, @Caption, @CaptionFull, 'ExtUrl', 'NeedsToBeConfigured.htm', '')
	END
	ELSE
	BEGIN
		INSERT INTO ResNowPage (MenuSectionSN, Active, Sort, ShowTime, Caption, CaptionFull, PageType, PageURL, CategoryCode, MetricCategorySN, PagePassword) 
		VALUES (@MenuSectionSN, @Active, @Sort, @ShowTime, @Caption, @CaptionFull, @PageType, @PageURL, @CategoryCode, @MetricCategorySN, '')
	END

GO
GRANT EXECUTE ON  [dbo].[MetricInsertResNowPage] TO [public]
GO

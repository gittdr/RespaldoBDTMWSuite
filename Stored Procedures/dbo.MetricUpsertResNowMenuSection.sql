SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpsertResNowMenuSection] (@Action varchar(12), @sn int,
	@Active int, @Sort int, @Caption varchar(40), @CaptionFull varchar(255), @CustomProcess int, @CustomPageTable varchar(30), @CustomAdminPageURL varchar(255)
)
AS
	SET NOCOUNT ON

	IF @Action = 'UPDATE'
		UPDATE ResNowMenuSection SET
			Active = @Active,
			Sort = @Sort,
			Caption = @Caption,
			CaptionFull = @CaptionFull,
            CustomProcess = @CustomProcess,
            CustomPageTable = @CustomPageTable,
			CustomAdminPageURL = @CustomAdminPageURL
		WHERE sn = @sn
	ELSE IF @Action = 'UPDATE2'
		UPDATE ResNowMenuSection SET
			Active = @Active,
			Sort = @Sort,
			Caption = @Caption,
			CaptionFull = @CaptionFull
			-- Don't update the other fields.
		WHERE sn = @sn		
	ELSE IF @Action = 'INSERT'
		INSERT INTO ResNowMenuSection (Active, Sort, Caption, CaptionFull, CustomProcess, CustomPageTable, CustomAdminPageURL) 
		VALUES (@Active, @Sort, @Caption, @CaptionFull, 0, '', '')
	ELSE IF @Action = 'INSERT2'
		INSERT INTO ResNowMenuSection (Active, Sort, Caption, CaptionFull, CustomProcess, MenuSystem) 
		VALUES (@Active, @Sort, @Caption, @CaptionFull, 0, '')
	ELSE IF @Action = 'DELETE'
	BEGIN
		DELETE ResNowPage WHERE MenuSectionSN = @sn
		DELETE ResNowMenuSection WHERE sn = @sn
	END
GO
GRANT EXECUTE ON  [dbo].[MetricUpsertResNowMenuSection] TO [public]
GO

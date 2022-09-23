SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[LabelfileEntryModify_sp]

	(
		@deleteall char(1),				--Set to Y to flush all labeldefinions matching labeldefinition prior to any add.  Will not delete 'UNK'
		@delete	char(1),				--Set to Y to delete, otherwise it's added or updated
		@labeldefinition varchar(20),	--internal name of label group referenced by system
		@name varchar(20),				--Individual label value seen by user
		@abbr varchar(6),				--Value stored for reference
		@code int						--Alternate value stored for reference
	)


AS

DECLARE @CurrentUserLabelName varchar(20)

SELECT @CurrentUserLabelName = userlabelname
FROM labelfile
WHERE labeldefinition = @labeldefinition

IF (@CurrentUserLabelName IS NULL) BEGIN
	SELECT @CurrentUserLabelName = @labeldefinition
END

IF (@deleteall = 'Y') BEGIN
	DELETE labelfile
	WHERE labeldefinition = @labeldefinition
			and abbr <> 'UNK'
END

IF (@Delete = 'Y') BEGIN
	DELETE labelfile
	WHERE labeldefinition = @labeldefinition
			and abbr = @abbr
END
ELSE BEGIN
	IF EXISTS(SELECT * 
				FROM labelfile
				WHERE labeldefinition = @labeldefinition
						and abbr = @abbr)					BEGIN
		UPDATE labelfile
		SET name = @name,
			code = @code
		WHERE labeldefinition = @labeldefinition
				and abbr = @abbr

	END 
	ELSE BEGIN
		INSERT INTO labelfile
							  (labeldefinition, name, abbr, code, locked, systemcode, retired, userlabelname)
		VALUES     (@labeldefinition, @name, @abbr, @code, 'N', 'N', 'N', @CurrentUserLabelName)
	END 
END

GO
GRANT EXECUTE ON  [dbo].[LabelfileEntryModify_sp] TO [public]
GO

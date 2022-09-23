SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricSetParameter] 
(
	@Heading varchar(100) = 'MetricStoredProc',
	@Subheading varchar(100)='',
	@ParmName varchar(100) = '',
	@ParmValue varchar(100)=''
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS	
	SET NOCOUNT ON

	IF EXISTS(SELECT * FROM MetricParameter WHERE Heading = @Heading and Subheading = @Subheading and parmname = @parmname)
	BEGIN
		Update MetricParameter
		Set parmvalue = @parmvalue
		Where Heading = @Heading 
			and Subheading = @Subheading
			and Parmname = @ParmName
	END

						

GO
GRANT EXECUTE ON  [dbo].[MetricSetParameter] TO [public]
GO

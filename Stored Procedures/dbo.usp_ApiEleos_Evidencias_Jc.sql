SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_ApiEleos_Evidencias_Jc](
@segmento varchar(100), 
@obtDocs varchar(1000),
@filenamef varchar(100)
)
as
begin
		
		INSERT INTO ApiEleosREvidencias(
		load_number,
		download_url,
		files_name)
		VALUES(
		@segmento, 
        @obtDocs,
        @filenamef)
end
GO

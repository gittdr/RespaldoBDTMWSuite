SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[d_edi214_status_bycomp_sp_dotnet] @p_cmpid varchar(8) = NULL, @p_edicmpid varchar(5) = B
AS

/**
 * 
 * NAME:
 * dbo.d_edi214_status_bycomp_sp_dotnet
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns a list of valid edi status codes to populate the 
 * dropdown datawindow in the edi214 window based on billto or company based setting.
 * 
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * 001 - status_code. This is the edi214 status code.
 * 002 - status_text. Text description of the edi status code
 * 003 - cmp_id	      Name of company(when using company based)
 *
 * PARAMETERS:
 * 001 - @p_cmpid, varchar(8), input, not null;
 *       This parameter indicates the company id for which the edi statuses
 *	 are being retrieved.
 *
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * NONE
 *
 * 
 * REVISION HISTORY:
 * 10/06/2005.01 � PTS30078 - A.Rossman � Initial Release
 * 01/09/2006.02 - PTS31218 - A.Rossman - Corrected sort order of items in dropdown for billto based EDI.
 * 10/23/2015    - PTS91115 - S.Kancharlapalli - Copied the proc 'd_edi214_status_bycomp_sp' from VSS to SVN and renamed to d_edi214_status_bycomp_sp_dotnet.
                              Populating Status Code dropdown with only status codes set in EDI settings (In .Net 16.20)
 **/




DECLARE	@v_status_list	varchar(25),
	@v_status_code	varchar(6),
	@v_status_count int,
	@v_nextpos	int,
	@v_startpos	int,
	@v_recordid	int,
	@v_edi_process	int
	

--Determine whether this is company based or billto based
SELECT @v_edi_process =  (SELECT ISNULL(gi_string1,1) FROM generalinfo where gi_name  = 'EDI_Notification_Process_Type')

SELECT @v_recordid = 0

--create a temp table for the result set
CREATE TABLE #status(
	status_code	varchar(6) null,
	cmp_id		varchar(8) null,
	status_text	varchar(30) DEFAULT 'Not Defined' null	--from labelfile
	)

--holding table for the status codes 
CREATE TABLE #edi214_status(
	rec_id	int		null,
	cmp_id	varchar(8)	null,
	status	varchar(25)	null
	)

--If this is company based and an actual company ID was passed	
IF @v_edi_process = 2 --AND @p_cmpid <>'UNKNOWN'
	BEGIN
	IF (SELECT COUNT(*) FROM	edi_214_profile WHERE	e214_cmp_id = @p_cmpid) > 0
	BEGIN /*1*/
		--load the records from the profile into a temp table
		IF @p_edicmpid = 'B' 
			INSERT  INTO #edi214_status(rec_id,cmp_id,status)
			SELECT	e214_id,
				e214_cmp_id,
				e214_edi_status
			FROM	edi_214_profile
			WHERE	e214_cmp_id = @p_cmpid AND billto_role_flag ='Y'	
			ORDER BY e214_id ASC
		IF @p_edicmpid = 'C'
			INSERT  INTO #edi214_status(rec_id,cmp_id,status)
			SELECT	e214_id,
				e214_cmp_id,
				e214_edi_status
			FROM	edi_214_profile
			WHERE	e214_cmp_id = @p_cmpid AND consignee_role_flag ='Y'	
			ORDER BY e214_id ASC
		IF @p_edicmpid = 'S'
			INSERT  INTO #edi214_status(rec_id,cmp_id,status)
			SELECT	e214_id,
				e214_cmp_id,
				e214_edi_status
			FROM	edi_214_profile
			WHERE	e214_cmp_id = @p_cmpid AND shipper_role_flag ='Y'	
			ORDER BY e214_id ASC
		IF @p_edicmpid = 'O'
			INSERT  INTO #edi214_status(rec_id,cmp_id,status)
			SELECT	e214_id,
				e214_cmp_id,
				e214_edi_status
			FROM	edi_214_profile
			WHERE	e214_cmp_id = @p_cmpid AND orderby_role_flag ='Y'	
			ORDER BY e214_id ASC
		IF @p_edicmpid = 'D'
			INSERT  INTO #edi214_status(rec_id,cmp_id,status)
			SELECT	e214_id,
				e214_cmp_id,
				e214_edi_status
			FROM	edi_214_profile
			WHERE	e214_cmp_id = @p_cmpid AND e214_ReplicateForEachDropFlag ='Y'	
			ORDER BY e214_id ASC





		SELECT  @v_status_count = COUNT(*) 
		FROM	#edi214_status

		WHILE	@v_status_count > 0
		BEGIN /*2*/

			--initialize vars
			SELECT	@v_startpos = 1,@v_nextpos = 1

			--get the next record id
			SELECT @v_recordid = MIN(rec_id) 
			FROM	#edi214_status 
			WHERE	rec_id > @v_recordid

			--get the status for the that record
			SELECT @v_status_list = status
			FROM	#edi214_status
			WHERE	rec_id = @v_recordid

			WHILE @v_nextpos > 0
			BEGIN/*3*/
				--check for the existance of a comma in the string
				SELECT @v_nextpos = CHARINDEX(',',@v_status_list,@v_startpos)
				IF @v_nextpos > 1
				    BEGIN /*4*/
					--if this is a comma separated list, get the first item and insert into the table
					SELECT @v_status_code = SUBSTRING(@v_status_list,@v_startpos,@v_nextpos - @v_startpos), @v_startpos = @v_nextpos + 1
					IF LEN(@v_status_code) > 0
					INSERT INTO #status(status_code,cmp_id)
						VALUES(@v_status_code,@p_cmpid)
				    END/*4*/		
				ELSE
				    BEGIN /*5*/
					--if there is only one item in the string insert into the table
					SELECT @v_status_code = SUBSTRING(@v_status_list,@v_startpos,LEN(@v_status_list) +1 - @v_startpos), @v_startpos = @v_nextpos + 1
					IF LEN(@v_status_code) > 0
					INSERT INTO #status(status_code,cmp_id)
						VALUES(@v_status_code,@p_cmpid)
				    END/*5*/

			END /*3*/

			SELECT @v_status_count = @v_status_count - 1

		END /*2*/	
	END/*1*/

	--update the temp table and get the description from the label file for each code
	UPDATE #status
	SET	status_text = name
	FROM	labelfile
	WHERE	labeldefinition = 'EDI214Status'
	    AND ISNULL(RTRIM(edicode),RTRIM(abbr)) = status_code
END
--For Billto based, get the entire list from the labelfile.
ELSE
 IF @p_cmpid <> 'UNKNOWN'	--Added 10/21
 INSERT INTO #status(status_code,status_text)
 	SELECT abbr,name
 	FROM	labelfile 
 	WHERE	labeldefinition = 'EDI214Status'
 	    AND ISNULL(retired,'N') ='N'
 	ORDER BY code ASC				--ajr 31218    

--final select
SELECT status_code,cmp_id,status_text FROM #status		
		

GO
GRANT EXECUTE ON  [dbo].[d_edi214_status_bycomp_sp_dotnet] TO [public]
GO

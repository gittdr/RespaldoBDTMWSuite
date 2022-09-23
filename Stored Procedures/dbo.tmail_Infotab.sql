SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_Infotab] 
		@ord					AS VARCHAR(20)
							 
AS

-- =============================================================================
-- Stored Proc: tmail_Infotab
-- Author     :	Created from email authored by Lori Brickley
-- Create date: 2014.03.04
-- Description:
--      
--      Outputs:
--      ------------------------------------------------------------------------
--
--      Input parameters:
--      ------------------------------------------------------------------------
--
-- =============================================================================
-- Modification Log:
-- PTS 74198 - VMS - 2014.03.04 - Adding this stored proc to my database
--

--tmail_Infotab '950256','XXX','8','YYY','','','','','','','','','','','','','','','','','','','',''
--select * from referencenumber

BEGIN

	CREATE TABLE #temp2 (sn int identity, Notes varchar(max), NotesNoWrap varchar(max),AttachedTo varchar(max), Regarding varchar(max),RegardingAbbr varchar(max),AttachedToKey varchar(max), NoteNum varchar(max))

	DECLARE @XML as varchar(max)

	DECLARE	@parm01 varchar(400), @parm01_label varchar(40), 
			@parm02 varchar(400), @parm02_label varchar(40), 
			@parm03 varchar(400), @parm03_label varchar(40), 
			@parm04 varchar(400), @parm04_label varchar(40), 
			@parm05 varchar(400), @parm05_label varchar(40), 
			@parm06 varchar(400), @parm06_label varchar(40), 
			@parm07 varchar(400), @parm07_label varchar(40), 
			@parm08 varchar(400), @parm08_label varchar(40), 
			@parm09 varchar(400), @parm09_label varchar(40), 
			@parm10 varchar(400), @parm10_label varchar(40), 
			@parm11 varchar(400), @parm11_label varchar(40), 
			@parm12 varchar(400), @parm12_label varchar(40)
			

	select ref_sequence, ref_type, ref_number 
	into #temp
	from referencenumber 
	where ref_table = 'orderheader' 
		and ref_tablekey = @ord 
		
		
	insert into #temp2 (Notes , NotesNoWrap ,AttachedTo , Regarding,RegardingAbbr,AttachedToKey , NoteNum )
	exec tmail_get_notes4_sp 'orderset',@ord,'','4000'	
	-- exec tmail_get_notes4_sp 'orderset',@ord,'','4000'	- VMS - just in case i didnt get cven proc

	--select * from #temp2
		
	--select * from #temp	
		
	select @parm01_label = isnull(ref_type,'') from #temp where ref_sequence = 1
	select @parm01 = isnull(ref_number,'') from #temp where ref_sequence = 1
		
	select @parm02_label = isnull(ref_type,'') from #temp where ref_sequence = 2
	select @parm02 = isnull(ref_number,'') from #temp where ref_sequence = 2

	select @parm03_label = isnull(ref_type,'') from #temp where ref_sequence = 3
	select @parm03 = isnull(ref_number,'') from #temp where ref_sequence = 3

	select @parm04_label = isnull(ref_type,'') from #temp where ref_sequence = 4
	select @parm04 = isnull(ref_number,'') from #temp where ref_sequence = 4

	select @parm05_label = isnull(ref_type,'') from #temp where ref_sequence = 5
	select @parm05 = isnull(ref_number,'') from #temp where ref_sequence = 5

	select @parm06_label = isnull(ref_type,'') from #temp where ref_sequence = 6
	select @parm06 = isnull(ref_number,'') from #temp where ref_sequence = 6

	select @parm07_label = isnull(ref_type,'') from #temp where ref_sequence = 7
	select @parm07 = isnull(ref_number,'') from #temp where ref_sequence = 7

	select @parm08_label = isnull(ref_type,'') from #temp where ref_sequence = 8
	select @parm08 = isnull(ref_number,'') from #temp where ref_sequence = 8

	select @parm09_label = isnull(ref_type,'') from #temp where ref_sequence = 9
	select @parm09 = isnull(ref_number,'') from #temp where ref_sequence = 9

	select @parm10_label = isnull(ref_type,'') from #temp where ref_sequence = 10
	select @parm10 = isnull(ref_number,'') from #temp where ref_sequence = 10

	select @parm11_label = isnull(ref_type,'') from #temp where ref_sequence = 11
	select @parm11 = isnull(ref_number,'') from #temp where ref_sequence = 11	
			
	select @parm12_label = isnull(ref_type,'') from #temp where ref_sequence = 12
	select @parm12 = isnull(ref_number,'') from #temp where ref_sequence = 12	
					
	select @XML = '<data id="InfoPlus">
					<datum name="type" value="info" />
					<data id="Info0">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="0" />
					  <datum name="customLabel" value="Reference Information" />
					  <datum name="customValue" value=" " />
					</data>
					<data id="Info1">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="1" />
					  <datum name="customLabel" value="'+isnull(@parm01_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm01,'')+'" />
					</data>
					<data id="Info2">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="2" />
					  <datum name="customLabel" value="'+isnull(@parm02_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm02,'')+'" />
					</data>
					<data id="Info3">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="3" />
					  <datum name="customLabel" value="'+isnull(@parm03_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm03,'')+'" />
					</data>
					<data id="Info4">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="4" />
					  <datum name="customLabel" value="'+isnull(@parm04_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm04,'')+'" />
					</data>
					<data id="Info5">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="5" />
					  <datum name="customLabel" value="'+isnull(@parm05_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm05,'')+'" />
					</data>
					<data id="Info6">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="6" />
					  <datum name="customLabel" value="'+isnull(@parm06_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm06,'')+'" />
					</data>
					<data id="Info7">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="7" />
					  <datum name="customLabel" value="'+isnull(@parm07_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm07,'')+'" />
					</data>
					<data id="Info8">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="8" />
					  <datum name="customLabel" value="'+isnull(@parm08_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm08,'')+'" />
					</data>
					<data id="Info9">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="9" />
					  <datum name="customLabel" value="'+isnull(@parm09_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm09,'')+'" />
					</data>
					<data id="Info10">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="10" />
					  <datum name="customLabel" value="'+isnull(@parm10_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm10,'')+'" />
					</data>
					<data id="Info11">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="11" />
					  <datum name="customLabel" value="'+isnull(@parm11_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm11,'')+'" />
					</data>
					<data id="Info12">
					  <datum name="type" value="customItem" />
					  <datum name="sortId" value="12" />
					  <datum name="customLabel" value="'+isnull(@parm12_label,'')+'" />
					  <datum name="customValue" value="'+isnull(@parm12,'')+'" />
					</data>
				  '


	select @parm01_label = 'Note 1' from #temp2 where SN = 1
	select @parm01 = isnull(Notes,'') from #temp2 where SN = 1
		
	select @parm02_label = 'Note 2' from #temp2 where SN = 2
	select @parm02 = isnull(Notes,'') from #temp2 where SN = 2

	select @parm03_label = 'Note 3' from #temp2 where SN = 3
	select @parm03 = isnull(Notes,'') from #temp2 where SN = 3

	select @parm04_label = 'Note 4' from #temp2 where SN = 4
	select @parm04 = isnull(Notes,'') from #temp2 where SN = 4

	select @parm05_label = 'Note 5' from #temp2 where SN = 5
	select @parm05 = isnull(Notes,'') from #temp2 where SN = 5

	select @parm06_label = 'Note 6' from #temp2 where SN = 6
	select @parm06 = isnull(Notes,'') from #temp2 where SN = 6

	select @parm07_label = 'Note 7' from #temp2 where SN = 7
	select @parm07 = isnull(Notes,'') from #temp2 where SN = 7

	select @parm08_label = 'Note 8' from #temp2 where SN = 8
	select @parm08 = isnull(Notes,'') from #temp2 where SN = 8

	select @parm09_label = 'Note 9' from #temp2 where SN = 9
	select @parm09 = isnull(Notes,'') from #temp2 where SN = 9

	select @parm10_label = 'Note 10' from #temp2 where SN = 10
	select @parm10 = isnull(Notes,'') from #temp2 where SN = 10

	select @parm11_label = 'Note 11' from #temp2 where SN = 11
	select @parm11 = isnull(Notes,'') from #temp2 where SN = 11	
			
	select @parm12_label = 'Note 12' from #temp2 where SN = 12
	select @parm12 = isnull(Notes,'') from #temp2 where SN = 12	


	select @XML = @XML + '<data id="Info20">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="20" />
			  <datum name="customLabel" value="Notes" />
			  <datum name="customValue" value=" " />
			</data>
			<data id="Info21">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="21" />
			  <datum name="customLabel" value="'+isnull(@parm01_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm01,'')+'" />
			</data>
			<data id="Info22">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="22" />
			  <datum name="customLabel" value="'+isnull(@parm02_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm02,'')+'" />
			</data>
			<data id="Info23">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="23" />
			  <datum name="customLabel" value="'+isnull(@parm03_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm03,'')+'" />
			</data>
			<data id="Info24">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="24" />
			  <datum name="customLabel" value="'+isnull(@parm04_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm04,'')+'" />
			</data>
			<data id="Info25">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="25" />
			  <datum name="customLabel" value="'+isnull(@parm05_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm05,'')+'" />
			</data>
			<data id="Info26">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="26" />
			  <datum name="customLabel" value="'+isnull(@parm06_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm06,'')+'" />
			</data>
			<data id="Info27">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="27" />
			  <datum name="customLabel" value="'+isnull(@parm07_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm07,'')+'" />
			</data>
			<data id="Info28">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="28" />
			  <datum name="customLabel" value="'+isnull(@parm08_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm08,'')+'" />
			</data>
			<data id="Info29">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="29" />
			  <datum name="customLabel" value="'+isnull(@parm09_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm09,'')+'" />
			</data>
			<data id="Info210">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="30" />
			  <datum name="customLabel" value="'+isnull(@parm10_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm10,'')+'" />
			</data>
			<data id="Info211">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="31" />
			  <datum name="customLabel" value="'+isnull(@parm11_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm11,'')+'" />
			</data>
			<data id="Info212">
			  <datum name="type" value="customItem" />
			  <datum name="sortId" value="32" />
			  <datum name="customLabel" value="'+isnull(@parm12_label,'')+'" />
			  <datum name="customValue" value="'+isnull(@parm12,'')+'" />
			</data>
		  </data>'
		  
	select @xml

END

GO
GRANT EXECUTE ON  [dbo].[tmail_Infotab] TO [public]
GO

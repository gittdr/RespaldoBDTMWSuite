SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO





--DriverAwareSuite_DriverFilterListValues 'StartRegion1'

CREATE    Procedure [dbo].[DriverAwareSuite_DriverFilterListValues] (@Parameter_Name varchar(255))

As

Set NoCount On

Declare @LookUpMethod varchar(255)
Declare @TableLookup varchar(255)
Declare @TableLookUpCodeColumn varchar(255)
Declare @TableLookUpDescColumn varchar(255)
Declare @TableLookUpRestrictColumn varchar(255)
Declare @PresName varchar(255)
Declare @SQL varchar(8000)
Declare @LabelAbbr varchar(255)
Declare @LabelDefinition varchar(255)

Select  @LookUpMethod = 
	 Case When DefaultControl = 'TableLookUp' Then
		'TableLookUp'
	 Else
		'LabelFile'
	 End,
	 @TableLookup = TableLookUp,
	 @TableLookUpCodeColumn = TableLookupCodeColumn,
	 @TableLookUpDescColumn = TableLookupDescColumn,
	 @TableLookUpRestrictColumn = TableLookupRestrictColumn,
	 @PresName = Pres_Name,
	 @LabelAbbr = LabelAbbr,
	 @LabelDefinition = Label_Definition 			       
From     DriverAwareSuite_LabelMappings
Where    DriverAwareSuite_LabelMappings.Parameter_Name = @Parameter_Name

If @LookupMethod = 'TableLookup'
Begin
	Set @SQL = 'Select ' + @TableLookUpCodeColumn + ' as CodeValue , ' + @TableLookUpDescColumn + ' as DisplayValue' +  ' ' + 
           	   'From ' + @TableLookUp + ' '
		   
	If @TableLookUpRestrictColumn Is Not Null
	Begin
		Set @SQL = @SQL + ' Where ' + @TableLookupRestrictColumn + ' = ' + '''' + @LabelAbbr + ''''
	End

	Set @SQL = @SQL +  ' ' + 'Order By ' + @TableLookUpDescColumn


	print @sql
	Exec (@SQL)
	
End
Else
Begin
	Select abbr as CodeValue,IsNull(name,@PresName) as DisplayValue
	from   LabelFile (NOLOCK)
	Where  labeldefinition = @LabelDefinition
           And
           IsNull(Retired,'N') = 'N'

	Order By Name ASC
End







GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_DriverFilterListValues] TO [public]
GO

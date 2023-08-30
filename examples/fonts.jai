#import "File";
#import "File_Utilities";

FindAllFonts :: (fonts_path: string) -> []string {
    fonts :[..]string;
    // 1. check if fonts_path exists:
    fl : []string = file_list(fonts_path);
    return fl;
}
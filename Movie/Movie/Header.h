//
//  Header.h
//  Movie
//
//  Created by lijian on 14-7-16.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#ifndef Movie_Header_h
#define Movie_Header_h

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)
#define degreesToRadian(x) (M_PI * x / 180.0)

#endif

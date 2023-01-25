program pascalGL;
{$mode objfpc}{$H+}

uses
    glfw, glad_gl, sysutils, math;

var 
    window: ^integer;

    shaderProgram: uint32;

    vertexShaderCode: string;
    vertexShader: uint32;

    fragmentShaderCode: string;
    fragmentShader: uint32;

    colourUniformLoc: int32;

    VAO: uint32;
    VBO: uint32;
    vertices: array[0..8] of single;

    deltaTime: single;
    lastTime: uint64;
    lastColour: single;
    count: single;

procedure onResize(window: pGLFWwindow; witdth, height: integer);
begin
  glViewport(0, 0, witdth, height);
end;

begin

    vertexShaderCode := '#version 330 core' + #13#10 +
    'layout (location = 0) in vec3 pos;' + #13#10 +
    'void main() {' + #13#10 +
    '  gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);' + #13#10 +
    '}';

    fragmentShaderCode := '#version 330 core' + #13#10 +
    'out vec4 FragColour;' + #13#10 +
    'uniform vec3 colour;' + #13#10 +
    'void main() {' + #13#10 +
    '  FragColour = vec4(colour.x, colour.y, colour.z, 1.0f);' + #13#10 +
    '}';

    vertices[0] := -0.5; vertices[1] := -0.5; vertices[2] := 0.0;
    vertices[3] := 0.5; vertices[4] := -0.5; vertices[5] := 0.0;
    vertices[6] := 0.0; vertices[7] := 0.5; vertices[8] := 0.0;

    if not glfwInit() = 1 then
    begin
        WriteLn('Failed to initialize GLFW');
        exit;
    end;
    WriteLn('Succssfully initialized GLFW');

    glfwDefaultWindowHints();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, 1);

    window := glfwCreateWindow(900, 600, 'Free Pascal + GLFW + OpenGL', nil, nil);

    glfwMakeContextCurrent(window);
    
    if not gladLoadGL(TLoadProc(@glfwGetProcAddress)) then
    begin
        WriteLn('Failed to initialize OpenGL context');
        glfwDestroyWindow(window);
        glfwTerminate();
        exit;
    end;
    WriteLn('Succesfully created OpenGL context');

    // vertex shader
    vertexShader := glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, @vertexShaderCode, nil);
    glCompileShader(vertexShader);

    // fragment shader
    fragmentShader := glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, @fragmentShaderCode, nil);
    glCompileShader(fragmentShader);

    shaderProgram := glCreateProgram();

    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    glDetachShader(shaderProgram, vertexShader);
    glDetachShader(shaderProgram, fragmentShader);

    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    colourUniformLoc := glGetUniformLocation(shaderProgram, 'colour');

    glGenVertexArrays(1, @VAO);
    glBindVertexArray(VAO);

    glGenBuffers(1, @VBO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, 36, @vertices, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, nil);
    glEnableVertexAttribArray(0);

    glViewport(0, 0, 900, 600);
    
    glfwSetFramebufferSizeCallback(window, GLFWframebuffersizefun(@onResize));

    glUseProgram(shaderProgram);
    glBindVertexArray(VAO);

    lastTime := glfwGetTimerValue();
    lastColour := Random;
    count := 0.0;

    while glfwWindowShouldClose(window) = 0 do
    begin
        
        glClear(GL_COLOR_BUFFER_BIT);
        glClearColor(0.2, 0.3, 0.3, 1.0);

        deltaTime := (glfwGetTimerValue()-lastTime)/1000000000;
        lastTime := glfwGetTimerValue();

        count := count + deltaTime;

        if count > 0.009 then
        begin
          lastColour := lastColour + 0.03;
          glUniform3f(colourUniformLoc,
            0.2,
            sin(lastColour)/2.0+0.5,
            cos(lastColour)/2.0+0.5
          );
          count := 0;
        end;

        glDrawArrays(GL_TRIANGLES, 0, 3);

        glfwSwapBuffers(window);
        glfwPollEvents();

    end;

    glDeleteBuffers(1, @VBO);
    glDeleteVertexArrays(1, @VAO);

    glfwSetFramebufferSizeCallback(window, nil);

    glfwDestroyWindow(window);
    glfwTerminate();

end.